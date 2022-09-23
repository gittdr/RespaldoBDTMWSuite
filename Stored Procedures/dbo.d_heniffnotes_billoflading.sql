SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_heniffnotes_billoflading] (@ordnum int)
AS

Declare
@consignee_id varchar(10), @counter int

CREATE TABLE #hbol_notes (
--STOP_EVENT varchar(10) NULL,
--CONSIGNEE_ID  VARCHAR(8) NULL,
SPECIAL_INSTR varchar(254) NULL
)

INSERT INTO #hbol_notes
--SELECT STP.STP_TYPE STOP_EVENT,       
--       CMP.CMP_ID CONSIGNEE_ID,          
--       ORD.ORD_REMARK SPECIAL_INSTR          
--  FROM orderheader    ord,         
--       stops	    stp,
--       company        cmp      
-- WHERE ORD.ORD_HDRNUMBER  = @ordnum           AND
--       ORD.ORD_HDRNUMBER  = STP.ORD_HDRNUMBER AND                    
--       STP.CMP_ID         *= CMP.CMP_ID  

SELECT ORD.ORD_REMARK SPECIAL_INSTR            
  FROM orderheader    ord         
 WHERE ORD.ORD_HDRNUMBER  = @ordnum  

--Initialize counter
--select @counter = 0

--Create a cursor based on the select statement below
--DECLARE note_cursor CURSOR FOR  
--SELECT #hbol_notes.CONSIGNEE_ID
--  FROM #hbol_notes 
-- WHERE STOP_EVENT = 'DRP'
    
--Populate the cursor based on the select statement above  
--OPEN note_cursor  
  
--Execute the initial fetch of the consignee
--FETCH NEXT FROM note_cursor INTO @consignee_id 
 
--If the fetch is succesful continue to loop
--WHILE @@fetch_status = 0  
-- BEGIN  
	--Increment counter for updates to notes, consignee name, city, state
        --SELECT @COUNTER = @COUNTER + 1

	--update the table woth any notes created for the consignee
	--UPDATE #hbol_notes
	--   SET SPECIAL_INSTR = NOTES.NOT_TEXT
	--  FROM NOTES, #hbol_notes
	-- WHERE NOTES.NRE_TABLEKEY = @consignee_id  AND
	--       NOTES.NTB_TABLE = 'COMPANY'	     AND
	--       NOTES.NOT_TYPE = 'C' and
        --       #hbol_notes.consignee_id = @consignee_id      
	
	--Reset variable
	--SELECT @consignee_id = ''

	--Fetch the next consignee name in the list
	--FETCH NEXT FROM note_cursor INTO @consignee_id
--  END

--Close cursor  
--CLOSE note_cursor

--Release cusor resources  
--DEALLOCATE note_cursor


--Get the final results set
--Select * from #hbol_notes where stop_event = 'DRP'
Select * from #hbol_notes
GO
GRANT EXECUTE ON  [dbo].[d_heniffnotes_billoflading] TO [public]
GO
