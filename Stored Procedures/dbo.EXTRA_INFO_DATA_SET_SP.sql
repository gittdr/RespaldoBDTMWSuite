SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[EXTRA_INFO_DATA_SET_SP](@HeaderTableName varchar(50), @TabName  varchar(50), @ColumnName varchar(50), @HeaderKeyValue varchar(50), @Value varchar(7665)) AS
BEGIN
/* Writes an extra info value to Row 1
	Parameters:
		@HeaderTableName: A valid value from EXTRA_INFO_HEADER.TABLE_NAME (eg. For Orders, this would be 'ord')
		@TabName: A valid value from EXTRA_INFO_TAB.TAB_NAME (This would be the name entered for the tab containing the value in the Extra Info Maintenance dialog)
		@ColumnName: A valid value from EXTRA_INFO_COLS.COL_NAME (This would be the name entered for the column in the Extra Info Maintenance dialog)
		@HeaderKeyValue: The header number for the object the note is to be attached to (eg. For Orders this would be the Order Header Number)
		@Value: The desired value to set
*/

--PTS 25551 Supporting SP to facilitate Extra value updating within the custom order post save stored procedure.

	UPDATE EXTRA_INFO_DATA
	SET	  EXTRA_INFO_DATA.COL_DATA  = @Value 
	FROM 	EXTRA_INFO_COLS,   
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
GRANT EXECUTE ON  [dbo].[EXTRA_INFO_DATA_SET_SP] TO [public]
GO
