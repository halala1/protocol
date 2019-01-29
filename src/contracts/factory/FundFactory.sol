pragma solidity ^0.4.21;
pragma experimental ABIEncoderV2;

import "Accounting.sol";
import "FeeManager.sol";
import "Hub.sol";
import "PolicyManager.sol";
import "Participation.sol";
import "Shares.sol";
import "Trading.sol";
import "Vault.sol";
import "Version.i.sol";
import "AmguConsumer.sol";
import "Factory.sol";

/// @notice Creates fund routes and links them together
contract FundFactory is AmguConsumer, Factory {

    event NewFund(
        address manager,
        address hub,
        address[12] routes
    );

    address public factoryPriceSource;
    address public mlnToken;
    VersionInterface public version;
    address public engine;
    address public registry;
    AccountingFactory public accountingFactory;
    FeeManagerFactory public feeManagerFactory;
    ParticipationFactory public participationFactory;
    PolicyManagerFactory public policyManagerFactory;
    SharesFactory public sharesFactory;
    TradingFactory public tradingFactory;
    VaultFactory public vaultFactory;

    address[] public funds;
    mapping (address => address) public managersToHubs;
    mapping (address => Hub.Routes) public managersToRoutes;
    mapping (address => Settings) public managersToSettings;

    /// @dev Parameters stored when beginning setup
    struct Settings {
        string name;
        address[] exchanges;
        address[] adapters;
        address denominationAsset;
        address nativeAsset;
        address[] defaultAssets;
        bool[] takesCustody;
        address priceSource;
        address[] fees;
        uint[] feeRates;
        uint[] feePeriods;
    }

    modifier componentNotSet(address _component) {
        require(
            !componentExists(_component),
            "This step has already been run"
        );
        _;
    }

    modifier componentSet(address _component) {
        require(
            componentExists(_component),
            "Component preprequisites not met"
        );
        _;
    }

    constructor(
        address _accountingFactory,
        address _feeManagerFactory,
        address _participationFactory,
        address _sharesFactory,
        address _tradingFactory,
        address _vaultFactory,
        address _policyManagerFactory,
        address _version,
        address _engine,
        address _factoryPriceSource,
        address _mlnToken
    ) {
        accountingFactory = AccountingFactory(_accountingFactory);
        feeManagerFactory = FeeManagerFactory(_feeManagerFactory);
        participationFactory = ParticipationFactory(_participationFactory);
        sharesFactory = SharesFactory(_sharesFactory);
        tradingFactory = TradingFactory(_tradingFactory);
        vaultFactory = VaultFactory(_vaultFactory);
        policyManagerFactory = PolicyManagerFactory(_policyManagerFactory);
        version = VersionInterface(_version);
        engine = Engine(_engine);
        factoryPriceSource = _factoryPriceSource;
        mlnToken = _mlnToken;
    }

    function componentExists(address _component) internal returns (bool) {
        return _component != address(0);
    }

    function beginSetup(
        string _name,
        address[] _fees,
        uint[] _feeRates,
        uint[] _feePeriods,
        address[] _exchanges,
        address[] _adapters,
        address _denominationAsset,
        address _nativeAsset,
        address[] _defaultAssets,
        bool[] _takesCustody,
        address _priceSource
    )
        public
        componentNotSet(managersToHubs[msg.sender])
    {
        require(!version.getShutDownStatus(), "Version is shut down");
        require(
            _nativeAsset == Registry(registry).nativeAsset(),
            "Native asset does not match registry"
        );
        managersToHubs[msg.sender] = new Hub(msg.sender, _name);
        managersToSettings[msg.sender] = Settings(
            _name,
            _exchanges,
            _adapters,
            _denominationAsset,
            _nativeAsset,
            _defaultAssets,
            _takesCustody,
            _priceSource,
            _fees,
            _feeRates,
            _feePeriods
        );
        managersToRoutes[msg.sender].priceSource = managersToSettings[msg.sender].priceSource;
        managersToRoutes[msg.sender].registry = registry;
        managersToRoutes[msg.sender].version = address(version);
        managersToRoutes[msg.sender].engine = engine;
        managersToRoutes[msg.sender].mlnToken = mlnToken;
    }

    function createAccounting()
        public
        componentSet(managersToHubs[msg.sender])
        componentNotSet(managersToRoutes[msg.sender].accounting)
        amguPayable(false)
        payable
    {
        managersToRoutes[msg.sender].accounting = accountingFactory.createInstance(
            managersToHubs[msg.sender],
            managersToSettings[msg.sender].denominationAsset,
            managersToSettings[msg.sender].nativeAsset,
            managersToSettings[msg.sender].defaultAssets
        );
    }

    function createFeeManager()
        public
        componentSet(managersToHubs[msg.sender])
        componentNotSet(managersToRoutes[msg.sender].feeManager)
        amguPayable(false)
        payable
    {
        managersToRoutes[msg.sender].feeManager = feeManagerFactory.createInstance(
            managersToHubs[msg.sender],
            managersToSettings[msg.sender].denominationAsset,
            managersToSettings[msg.sender].fees,
            managersToSettings[msg.sender].feeRates,
            managersToSettings[msg.sender].feePeriods
        );
    }

    function createParticipation()
        public
        componentSet(managersToHubs[msg.sender])
        componentNotSet(managersToRoutes[msg.sender].participation)
        amguPayable(false)
        payable
    {
        managersToRoutes[msg.sender].participation = participationFactory.createInstance(
            managersToHubs[msg.sender],
            managersToSettings[msg.sender].defaultAssets,
            managersToRoutes[msg.sender].registry
        );
    }

    function createPolicyManager()
        public
        componentSet(managersToHubs[msg.sender])
        componentNotSet(managersToRoutes[msg.sender].policyManager)
        amguPayable(false)
        payable
    {
        managersToRoutes[msg.sender].policyManager = policyManagerFactory.createInstance(
            managersToHubs[msg.sender]
        );
    }

    function createShares()
        public
        componentSet(managersToHubs[msg.sender])
        componentNotSet(managersToRoutes[msg.sender].shares)
        amguPayable(false)
        payable
    {
        managersToRoutes[msg.sender].shares = sharesFactory.createInstance(
            managersToHubs[msg.sender]
        );
    }

    function createTrading()
        public
        componentSet(managersToHubs[msg.sender])
        componentNotSet(managersToRoutes[msg.sender].trading)
        amguPayable(false)
        payable
    {
        managersToRoutes[msg.sender].trading = tradingFactory.createInstance(
            managersToHubs[msg.sender],
            managersToSettings[msg.sender].exchanges,
            managersToSettings[msg.sender].adapters,
            managersToSettings[msg.sender].takesCustody,
            managersToRoutes[msg.sender].registry
        );
    }

    function createVault()
        public
        componentSet(managersToHubs[msg.sender])
        componentNotSet(managersToRoutes[msg.sender].vault)
        amguPayable(false)
        payable
    {
        managersToRoutes[msg.sender].vault = vaultFactory.createInstance(
            managersToHubs[msg.sender]
        );
    }

    function completeSetup() public amguPayable(false) payable {
        Hub.Routes routes = managersToRoutes[msg.sender];
        Hub hub = Hub(managersToHubs[msg.sender]);
        require(!childExists[address(hub)], "Setup already complete");
        require(
            componentExists(hub) &&
            componentExists(routes.accounting) &&
            componentExists(routes.feeManager) &&
            componentExists(routes.participation) &&
            componentExists(routes.policyManager) &&
            componentExists(routes.shares) &&
            componentExists(routes.trading) &&
            componentExists(routes.vault),
            "Components must be set before completing setup"
        );
        childExists[address(hub)] = true;
        hub.setSpokes([
            routes.accounting,
            routes.feeManager,
            routes.participation,
            routes.policyManager,
            routes.shares,
            routes.trading,
            routes.vault,
            routes.priceSource,
            routes.registry,
            routes.version,
            routes.engine,
            routes.mlnToken
        ]);
        hub.setRouting();
        hub.setPermissions();
        funds.push(hub);
        Registry(registry).registerFund(
            address(hub),
            msg.sender,
            managersToSettings[msg.sender].name
        );

        emit NewFund(
            msg.sender,
            hub,
            [
                routes.accounting,
                routes.feeManager,
                routes.participation,
                routes.policyManager,
                routes.shares,
                routes.trading,
                routes.vault,
                routes.priceSource,
                routes.registry,
                routes.version,
                routes.engine,
                routes.mlnToken
            ]
        );
    }

    function getFundById(uint withId) public view returns (address) { return funds[withId]; }
    function getLastFundId() public view returns (uint) { return funds.length - 1; }

    function engine() public view returns (address) { return address(engine); }
    function mlnToken() public view returns (address) { return address(mlnToken); }
    function priceSource() public view returns (address) { return address(factoryPriceSource); }
    function version() public view returns (address) { return address(version); }
    function registry() public view returns (address) { return address(registry); }
}

