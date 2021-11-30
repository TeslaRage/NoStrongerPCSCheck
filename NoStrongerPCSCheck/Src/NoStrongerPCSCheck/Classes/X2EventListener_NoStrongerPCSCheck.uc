class X2EventListener_NoStrongerPCSCheck extends X2EventListener;

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

	// Grab everything we need from event
	OverrideTuple = XComLWTuple(EventData);
	Implant = XComGameState_Item(OverrideTuple.Data[1].o);
	Unit = XComGameState_Unit(EventSource);
	CanEquipImplant = OverrideTuple.Data[0].b;

	// If the unit can already equip, we bail
	if (CanEquipImplant) return ELR_NoInterrupt;

	// This retains the original behaviour of Psi stat check
	if (class'UIUtilities_Strategy'.static.GetStatBoost(Implant).StatType == eStat_PsiOffense && !Unit.IsPsiOperative())
		return ELR_NoInterrupt;

	// If unit does not have any equipped implant, we bail
	EquippedImplants = Unit.GetAllItemsInSlot(eInvSlot_CombatSim);

	if (EquippedImplants.Length <= 0) return ELR_NoInterrupt;
	
	// Even when the new PCS is weaker than the equipped one, we allow it to be equipped
	ImplantToRemove = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(EquippedImplants[0].ObjectID));

	if(class'UIUtilities_Strategy'.static.GetStatBoost(Implant).StatType == 
		class'UIUtilities_Strategy'.static.GetStatBoost(ImplantToRemove).StatType  && 
		class'UIUtilities_Strategy'.static.GetStatBoost(Implant).Boost <= 
		class'UIUtilities_Strategy'.static.GetStatBoost(ImplantToRemove).Boost)
		CanEquipImplant = true;

	OverrideTuple.Data[0].b = CanEquipImplant;
	
	return ELR_NoInterrupt;
}