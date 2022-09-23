SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/*  
Created for TMI on PTS 17833  
Example call   
exec TMI_imagingrecord_DTSEMove  
  
Stored proc created to populate the a temporary table with all the flat file  
records created by TMI_imagingrecord_100EMove, based on the values in ImageMoveList  
*/  
  
CREATE Procedure [dbo].[TMI_imagingrecord_DTSEMove]   
As  
  
SET NOCOUNT ON  
  
Declare @movnumber int, @iml_id int  
  
--Create a cursor to loop though all mov_number(s) on the ImageMoveList.db  
--which will create a flat file for each record in the list.   
  
--Create a cursor based on the select statement below  
DECLARE movnumber_cursor CURSOR FOR    
SELECT mov_number, iml_id  
  FROM ImageMoveList   
      
--Populate the cursor based on the select statement above    
OPEN movnumber_cursor    
    
--Execute the initial fetch of the first ord_hdrnumber  
FETCH NEXT FROM movnumber_cursor INTO @movnumber, @iml_id   
    
--If the fetch is succesful continue to loop  
WHILE @@fetch_status = 0    
 BEGIN    
    
   --Populate the temporary table with the Flat File record created  
   INSERT INTO TMI_ImagingRecords (flat_file_record) EXEC TMI_imagingrecord_100EMove @movnumber  
     
   --Update temporary table with identity column to be used for deletion process  
   UPDATE TMI_ImagingRecords   
      SET iol_id = @iml_id  ,ir_type = 'M' 
    WHERE ir_id = (select max(ir_id) from TMI_ImagingRecords)  
  
   --Fetch the next ord_hdrnumber in the list  
   FETCH NEXT FROM movnumber_cursor INTO @movnumber, @iml_id    
    
 END    
    
--Close cursor    
CLOSE movnumber_cursor  
--Release cusor resources    
DEALLOCATE movnumber_cursor   
    
--Select all the records in the temporary table.  
--SELECT flat_file_record FROM TMI_ImagingRecords  
  
GO
GRANT EXECUTE ON  [dbo].[TMI_imagingrecord_DTSEMove] TO [public]
GO
