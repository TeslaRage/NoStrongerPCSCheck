class X2EventListener_NoStrongerPCSCheck extends X2EventListener config (PCSCheck);

struct SoldierClassPCSPrefixData
{
	var name SoldierClass;
	var string PCSPrefix;
};

var config array<SoldierClassPCSPrefixData> DisallowedClasses;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateStrategyListener());	

	return Templates;
}

static final function CHEventListenerTemplate CreateStrategyListener()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'X2EventListener_NoStrongerPCSCheck');

	Template.RegisterInStrategy = true;

	Template.AddCHEvent('OverrideCanEquipImplant', OverrideCanEquipImplant, ELD_Immediate, 99);

	return Template; 
}

static function EventListenerReturn OverrideCanEquipImplant(Object EventData, Object EventSource, XComGameState NewGameState, Name EventID, Object CallbackObject)
{
	local XComLWTuple OverrideTuple;
	local XComGameState_Item Implant, ImplantToRemove;
	local array<XComGameState_Item> EquippedImplants;
	local XComGameState_Unit Unit;
	local bool CanEquipImplant;
	local int i;

	// Grab everything we need from event
	OverrideTuple = XComLWTuple(EventData);
	Implant = XComGameState_Item(OverrideTuple.Data[1].o);
	Unit = XComGameState_Unit(EventSource);
	CanEquipImplant = OverrideTuple.Data[0].b;

	// Set to true and override everything from base game
	CanEquipImplant = true;

	// Check if the unit soldier class is allowed to equip the PCS based on prefix
	for (i = 0; i < default.DisallowedClasses.Length; i++)
	{
		if (default.DisallowedClasses[i].SoldierClass == Unit.GetSoldierClassTemplate().DataName
			&& default.DisallowedClasses[i].PCSPrefix == Left(Implant.GetMyTemplate().DataName, Len(default.DisallowedClasses[i].PCSPrefix)))
		{
			CanEquipImplant = false;
			break;
		}
	}

	OverrideTuple.Data[0].b = CanEquipImplant;
	
	return ELR_NoInterrupt;
}