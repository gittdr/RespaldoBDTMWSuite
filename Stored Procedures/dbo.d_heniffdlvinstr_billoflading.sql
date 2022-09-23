SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE  PROCEDURE [dbo].[d_heniffdlvinstr_billoflading] (@ordnum int)
AS
/**
 * DESCRIPTION:
 *
 * REVISION HISTORY:
 * 10/26/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

Declare
@consignee_id varchar(10), @counter int, @ORD_REMARKS VARCHAR(254),@stp_comment varchar(40)

CREATE TABLE #hbol_dlvinstr (
STOP_EVENT VARCHAR(10) NULL,
CONSIGNEE_ID  VARCHAR(8) NULL,
DELIVERY_INSTR VARCHAR(254) NULL
)

INSERT INTO #hbol_dlvinstr
SELECT          
       STP.STP_TYPE STOP_EVENT,             
       CMP.CMP_ID CONSIGNEE_ID, 
       STP.STP_COMMENT DELIVERY_INSTR   
FROM  stops stp  LEFT OUTER JOIN  company cmp  ON  STP.CMP_ID  = CMP.CMP_ID ,
	 orderheader ord 
WHERE	 ORD.ORD_HDRNUMBER  = @ordnum
 AND	ORD.ORD_HDRNUMBER  = STP.ORD_HDRNUMBER

/*
--Initialize counter
select @counter = 0

--Create a cursor based on the select statement below
DECLARE note_cursor CURSOR FOR  
SELECT #hbol_dlvinstr.CONSIGNEE_ID
  FROM #hbol_dlvinstr 
 WHERE STOP_EVENT = 'DRP'
    
--Populate the cursor based on the select statement above  
OPEN note_cursor  
  
--Execute the initial fetch of the consignee
FETCH NEXT FROM note_cursor INTO @consignee_id 
 
--If the fetch is succesful continue to loop
WHILE @@fetch_status = 0  
 BEGIN  
	--Commented Per Brad Young due to a change in the Spec dated 06/08/2004
	--The original spec called for the Delivery instr to be pulled fronm the 
	--notes table based on a note type of 'DI', the client has change the spec
        --to require the delivery instr be pulled from the stops table(stp_comment) 
	--Increment counter for updates to notes, consignee name, city, state
        --SELECT @COUNTER = @COUNTER + 1

	--update the table with any delivery instructions created for the consignee
	--UPDATE #hbol_dlvinstr
	--  SET DELIVERY_INSTR = NOTES.NOT_TEXT
	--  FROM NOTES, #hbol_dlvinstr
	-- WHERE NOTES.NRE_TABLEKEY = @consignee_id  AND
	--       NOTES.NTB_TABLE = 'COMPANY'	     AND
	--       NOTES.NOT_TYPE = 'DI' and
        --       #hbol_dlvinstr.consignee_id = @consignee_id     
	--Commented Per Brad Young due to a change in the Spec dated 06/08/2004
	
	--Reset variable
	--SELECT @consignee_id = ''               

	--Fetch the next consignee name in the list
	--FETCH NEXT FROM note_cursor INTO @consignee_id
  --END

--Close cursor  
--CLOSE note_cursor

--Release cusor resources  
--DEALLOCATE note_cursor
*/

--Get the final results set
Select * from #hbol_dlvinstr where stop_event = 'DRP' and isnull(delivery_instr,'') <> ''
GO
GRANT EXECUTE ON  [dbo].[d_heniffdlvinstr_billoflading] TO [public]
GO
