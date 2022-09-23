SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--@sTruckName   PowerSuite Truck. 
--
--
--@GroupName    Non-Mobile TotalMail Group to Remove Truck From
--

CREATE PROCEDURE [dbo].[tm_RemoveTruckFromNonMobileCommGroup] @sTruckName varchar(8), 
   	   				              @sGroupName varchar(15)
AS

SET NOCOUNT ON

DECLARE @iTruckSN int, 
        @iDefualtCabUnitSN int, 
	@iDefaultGroupCabUnitSN int, 
	@iGroupSN int

--Get the TotalMail Truck Name for the Powersuite Truck Name
SELECT @iTruckSN = SN 
FROM tblTrucks (NOLOCK)
WHERE DispSysTruckID = @sTruckName

if isnull(@iTruckSN, 0) = 0
	RETURN

--Get the Group DefaultCabUnitSN
SELECT @iDefaultGroupCabUnitSN = DefaultCabUnit 
FROM tblTrucks (NOLOCK)
WHERE TruckName = @sGroupName AND GroupFlag = 2

if ISNULL(@iDefaultGroupCabUnitSN, 0) = 0
	RETURN

--Get the TotalMail trucks DefaultCabUnitSN
SELECT @iDefualtCabUnitSN = DefaultCabUnit 
FROM tblTrucks (NOLOCK)
WHERE SN = @iTruckSN

if ISNULL(@iDefualtCabUnitSN, 0) = 0
	RETURN

--see if the truck is in the group
SELECT @iGroupSN = GroupCabSN
FROM tblCabUnitGroups (NOLOCK)
WHERE GroupCabSN = @iDefaultGroupCabUnitSN AND MemberCabSN = @iDefualtCabUnitSN

--if the truck is in the Group then delete it
if ISNULL(@iGroupSN, 0) > 0 
	DELETE tblCabUnitGroups
	WHERE GroupCabSN = @iDefaultGroupCabUnitSN AND MemberCabSN = @iDefualtCabUnitSN

GO
GRANT EXECUTE ON  [dbo].[tm_RemoveTruckFromNonMobileCommGroup] TO [public]
GO
