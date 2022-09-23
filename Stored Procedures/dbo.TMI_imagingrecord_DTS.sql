SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/*
Created for TMI on PTS 15477
Example call 
exec TMI_imagingrecord_DTS

Stored proc created to populate the a temporary table with all the flat file
records created by TMI_imagingrecord_100, based on the values in ImageOrderList
*/

CREATE Procedure [dbo].[TMI_imagingrecord_DTS] 
As

SET NOCOUNT ON

Declare @ord_hdrnumber int, @iol_id int

--Create a cursor to loop though all ord_hdrnumber(s) on the ImageOrderList.db
--which will create a flat file for each record in the list. 

--Create a cursor based on the select statement below
DECLARE ordhdrnumber_cursor CURSOR FOR  
SELECT ord_hdrnumber, iol_id
  FROM ImageOrderList 
    
--Populate the cursor based on the select statement above  
OPEN ordhdrnumber_cursor  
  
--Execute the initial fetch of the first ord_hdrnumber
FETCH NEXT FROM ordhdrnumber_cursor INTO @ord_hdrnumber, @iol_id 
  
--If the fetch is succesful continue to loop
WHILE @@fetch_status = 0  
 BEGIN  
  
   --Populate the temporary table with the Flat File record created
   INSERT INTO TMI_ImagingRecords (flat_file_record) EXEC TMI_imagingrecord_100 @ord_hdrnumber
   
   --Update temporary table with identity column to be used for deletion process
   UPDATE TMI_ImagingRecords 
      SET iol_id = @iol_id ,ir_type = 'O'
    WHERE ir_id = (select max(ir_id) from TMI_ImagingRecords)

   --Fetch the next ord_hdrnumber in the list
   FETCH NEXT FROM ordhdrnumber_cursor INTO @ord_hdrnumber, @iol_id  
  
 END  
  
--Close cursor  
CLOSE ordhdrnumber_cursor
--Release cusor resources  
DEALLOCATE ordhdrnumber_cursor 
  
--Select all the records in the temporary table.
--SELECT flat_file_record FROM TMI_ImagingRecords

GO
GRANT EXECUTE ON  [dbo].[TMI_imagingrecord_DTS] TO [public]
GO
