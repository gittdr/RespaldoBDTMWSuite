SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tm_CreateMemberGroup]   @sNewName varchar(50), @sOldName varchar(50),@iRetired int, @flags int 

As

/**
 * 
 * NAME:
 
 * dbo.tm_sk_CreateMemberGroup
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Creates a member group in TM configuration
 *
 * RETURNS:
 * none
 *
 * RESULT SETS: 
 * none
 *
 * PARAMETERS:
 * @sMewmber varchar(30)-  name of the new member group to be created
 * @sOldName varchar(50)  -current group name used to update all old member groups with changes
 * @iRetired int - used to update a current dispatch group for retirement
 * @flags int - Used to set paratemeters for tm_cofig Truck
	1 - mobil comm group
	2- Non mobile comm group
	
 *
 * REFERENCES:
 * none
 * 
 * REVISION HISTORY:
 * 02/29/2012 - PTS59916- JC - created
 *
 **/

DECLARE @debug int,
		@trucksn int,
		@cabsn int
		
		
Set @debug = 0 --0 = OFF / 1 = On,  Used to work out issues for future use


------------------------------------------------------------
--Debug
If @debug > 0 begin
		print 'tm_CreateMemberGroup Before...'
		select @sNewName, @flags
		select * from tblTrucks where TruckName = @sNewName
		select * from tblCabUnits where UnitID LIKE '%NONMC%'
		select @trucksn, @cabsn

end
------------------------------------------------------------

-------Member Group Create in TBLTrucks-----------------------------------------------------------------------------------
--use tm_configtruck to create new member or update member group 
exec tm_ConfigTruck2 @sNewName, @sOldName, '', '','', '', @iRetired,'', @flags 

------------------------------------------------------------
--Debug
If @debug > 0 
	begin
		print 'tm_CreateMemberGroup after...'
		select @sNewName, @flags
		select * from tblTrucks where TruckName = @sNewName
		select * from tblCabUnits where UnitID LIKE '%NONMC%'
		select @trucksn, @cabsn
END
------------------------------------------------------------








GO
GRANT EXECUTE ON  [dbo].[tm_CreateMemberGroup] TO [public]
GO
