SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[tm_GetMessages] @Tractor varchar(13), @MaxRecords int, @DoNotIncludeFormID int
AS

/*for testing
·	DECLARE @Tractor varchar(15) --PowerSuite Tractor ID
·	DECLARE @DoNotIncludeFormID int—PowerSuite Tractor ID
·	DECLARE @MaxRecords int
·	select @Tractor = '11664'
·	select DoNotIncludeFormID = 0
·	select @MaxRecords = 50
*/
-- For DoNotIncludeFormID, 0 will disable text messages (or any other non-form message).
--      so use -1 to show all.

SET NOCOUNT ON

IF isnull(@DoNotIncludeFormID, -2) < -1
SELECT @DoNotIncludeFormID = 0
IF ISNULL(@MaxRecords, 0) > 0 
SET ROWCOUNT @MaxRecords
SELECT tblmsgsharedata.origmsgsn, tblMsgShareData.MsgImage, EDProp.Value as ErrListID, tblErrorData.Description as ErrorDescription, DTSent
FROM 
	tblHistory (NOLOCK)
	INNER JOIN tblTrucks (NOLOCK) ON tblHistory.TruckSN = tblTrucks.SN
	INNER JOIN tblMessages (NOLOCK) ON tblMessages.SN = tblHistory.MsgSN
	INNER JOIN tblMsgShareData (NOLOCK) ON tblMessages.OrigMsgSN = tblMsgShareData.OrigMsgSN 
	LEFT OUTER JOIN 
			(tblMsgProperties EDProp (NOLOCK)
			INNER JOIN tblErrorData (NOLOCK) ON tblErrorData.SN = EDProp.Value AND EDProp.PropSN = 6) 
		ON EDProp.MsgSN = tblHistory.MsgSN
	LEFT OUTER JOIN 
			(tblMsgProperties FormProp (NOLOCK)
			INNER JOIN tblForms (NOLOCK) ON tblForms.SN = FormProp.Value AND FormProp.PropSN = 2) 
		ON FormProp.MsgSN = tblHistory.MsgSN
WHERE
	tblTrucks.DispSysTruckID = @Tractor
	AND ISNULL(tblForms.FormID, 0) <> @DoNotIncludeFormID 
	AND tblMessages.FromType IN (4,5,6)
ORDER BY DTSent DESC

SET ROWCOUNT 0
GO
GRANT EXECUTE ON  [dbo].[tm_GetMessages] TO [public]
GO
