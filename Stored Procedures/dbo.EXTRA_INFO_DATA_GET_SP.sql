SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[EXTRA_INFO_DATA_GET_SP](@HeaderTableName varchar(50), @TabName  varchar(50), @ColumnName varchar(50), @HeaderKeyValue varchar(50), @Value varchar(7665) OUTPUT) AS
BEGIN
/* Reads an extra info value from Row 1
	Parameters:
		@HeaderTableName: A valid value from EXTRA_INFO_HEADER.TABLE_NAME (eg. For Orders, this would be 'ord')
		@TabName: A valid value from EXTRA_INFO_TAB.TAB_NAME (This would be the name entered for the tab containing the value in the Extra Info Maintenance dialog)
		@ColumnName: A valid value from EXTRA_INFO_COLS.COL_NAME (This would be the name entered for the column in the Extra Info Maintenance dialog)
		@HeaderKeyValue: The header number for the object the note is to be attached to (eg. For Orders this would be the Order Header Number)
		@Value: The current value to stored in this parameter for return.  Returns Null if not found.
*/

--PTS 25551 Supporting SP to facilitate Extra value retrieval within the custom order post save stored procedure.

	SET @Value = Null

	SELECT @Value = EXTRA_INFO_DATA.COL_DATA  
	FROM 	EXTRA_INFO_COLS,   
		EXTRA_INFO_DATA,   
		EXTRA_INFO_HEADER,   
		EXTRA_INFO_TAB  
	WHERE ( EXTRA_INFO_COLS.COL_ID = EXTRA_INFO_DATA.COL_ID ) and  
		( EXTRA_INFO_DATA.EXTRA_ID = EXTRA_INFO_HEADER.EXTRA_ID ) and  
		( EXTRA_INFO_DATA.TAB_ID = EXTRA_INFO_TAB.TAB_ID ) and  
		(( EXTRA_INFO_HEADER.TABLE_NAME = @HeaderTableName ) AND  
		( EXTRA_INFO_TAB.TAB_NAME = @TabName ) AND  
		( EXTRA_INFO_COLS.COL_NAME = @ColumnName ) AND  
		( EXTRA_INFO_DATA.TABLE_KEY = @HeaderKeyValue ) AND
		( EXTRA_INFO_DATA.COL_ROW = 1 )  )    

END
GO
GRANT EXECUTE ON  [dbo].[EXTRA_INFO_DATA_GET_SP] TO [public]
GO
