SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--IN
--@GroupType    NULL or Group Type to retrieve
--		0 = All Groups
-- 		1 = Mobile Comm Groups
--		2 = Non Mobile Comm Groups
--
--@sTruckName   Null or PowerSuite Truck. If NULL all Group Definitions are returned
--		If Not NULL returns the TotalMail Groups that the truck is in
--

--Out: recordset with two columns:
--GroupName = Name of the Group Definition
--
--GroupFlag = 1 - QualComm Group
--	      2 - Non-Moblie Comm Group
--

CREATE PROCEDURE [dbo].[tm_GetGroupDefs](@GroupType as int, @sTruckName varchar(8))

AS

SET NOCOUNT ON

DECLARE @TotalMailTruckName varchar(15), @GroupFlag1 int, @GroupFlag2 int
	
	if ISNULL(@GroupType, 0) > 0 
		if @GroupType < 2
			BEGIN
				IF @GroupType = 1 
					BEGIN
						SELECT @GroupFlag1 = 1
						SELECT @GroupFlag2 = 1
					END
				else
					BEGIN
						SELECT @GroupFlag1  = 2
						SELECT @GroupFlag2  = 2
					END
			END	
		else
			BEGIN
				SELECT @GroupFlag1  = 1
				SELECT @GroupFlag2  = 2
			END
	else
		BEGIN
			SELECT @GroupFlag1  = 1
			SELECT @GroupFlag2  = 2
		END

	if ISNULL(@sTruckName, '') > '' 
		BEGIN
			--Get the TotalMail Truck Name for the Powersuite Truck Name
			SELECT @TotalMailTruckName = TruckName 
			FROM tblTrucks (NOLOCK)
			WHERE DispSysTruckID = @sTruckName
			if isnull(@TotalMailTruckName, '') = '' 
				BEGIN
					SELECT truckname GroupName, GroupFlag 
					from tbltrucks (NOLOCK)
					where 1=2
					RETURN
				END

			--Get the Groups for a Truck
			SELECT truckname GroupName, GroupFlag 
			from tbltrucks (NOLOCK)
			where sn in 
			(select LinkedObjSN 
				from tblcabunits (NOLOCK)
				where sn in 
			(select groupcabsn 
				from tblcabunitgroups (NOLOCK)
				where membercabsn in 
			(select sn 
				from tblcabunits (NOLOCK)
				where truck = 
			(select sn 
				from tbltrucks (NOLOCK)
				where truckname = @TotalMailTruckName )))) AND GroupFlag IN (@GroupFlag1, @GroupFlag2)

		END
	else	
		SELECT TruckName GroupName, GroupFlag 
		FROM tblTrucks (NOLOCK)
		WHERE GroupFlag > 0

GO
GRANT EXECUTE ON  [dbo].[tm_GetGroupDefs] TO [public]
GO
