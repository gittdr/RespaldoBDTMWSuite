SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create PROCEDURE [dbo].[tm_GET_TblAddressesDatabyTruck1]
	@ToName varchar(30),
	@Flag int 
	
	


 

AS

/**
 * 
 * NAME:
 * dbo.[tm_GET_TblAddressesDatabyTruck1]
 *
 * TYPE:
 * StoredProcedure 
 *
 * DESCRIPTION:
 * Pulls PropSN, FldType and TypeName value base on a EntryType and PropSN
 *  
 * RETURNS:
 * none.
 *
 * RESULT SETS: 
 * PropSN, FldType and TypeName fields
 *
 * PARAMETERS:
 * 001 - @Flag int
 * 	 1 = Flag UseInResolve
 *
 *      
 *
 * REVISION HISTORY:
 * 05/14/12      - PTS 60785 SJ - Created Stored Procedure for Email Agent
 **/

/* [tm_GET_TblAddressesDatabyTruck1]
 **************************************************************
*********************************************************************************/
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @sSQL nvarchar(1000)--,
--@truck varchar (10),
--@Group varchar (10),
--@Unk varchar (10)

--set @truck = 'TRUCK'
--set @Group = 'GROUP'
--set @Unk = '<UNK>'

SET @sSQL = N'SELECT ad.AddressType, AddressName, AddresseeType = 
CASE WHEN ad.AddressType = 4 THEN CASE WHEN ISNULL(GroupFlag, -1) = 0 THEN '' Truck ''' 
SET @sSQL = @sSql + N' WHEN ISNULL(GroupFlag, -1) > 0 THEN ''[Group] '''
SET @sSQL = @sSql + N' ELSE  ''Unk ''' 
SET @sSQL = @sSql + N' END ELSE ty.Description END 
FROM dbo.tblAddresses ad 
INNER JOIN tblAddressTypes ty ON ad.AddressType = ty.SN 
LEFT JOIN tblTrucks tr ON tr.TruckName = ad.AddressName 
WHERE AddressName = ''' + @ToName + ''''
print @ssql

IF @Flag & 1 = 1 
BEGIN 
print 2
SET @sSQL = @sSql + N' AND UseInResolve = 1'
END
EXEC SP_ExecuteSQL @sSQL 


GO
GRANT EXECUTE ON  [dbo].[tm_GET_TblAddressesDatabyTruck1] TO [public]
GO
