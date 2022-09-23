SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

/*
Created for TMI on PTS 15477 to replace TMI_imagingrecord_30DayHist
Example call 
exec TMI_imagingrecord_90DayHist

Stored proc created to get the 90 day history of orders. The proc will populate
ImageOrderList with all ord_hdrnumber values from the orderheader.db where the 
ord_bookedDate is 90 days or less prior to today and the value does not currently 
exist in ImageOrderList

DPETE 1/22/03 TMI requests records with assets only
*/

CREATE Procedure [dbo].[TMI_imagingrecord_90DayHist] 
As

Declare @ord_hdrnumber int

 --Create a cursor to loop though all ord_hdrnumber(s) on the orderheader.db.
 --to determine which orders have a book date 90 days or less prior to today. If
 --the book date is 90 days or less than today and the record does not exists in 
 --ImageOrderList then insert the new record.  
  
 --Determine if the vendor is TMI
IF (SELECT UPPER(gi_string1)
      FROM generalinfo
     WHERE gi_name = 'ImagingVendorOnRoad')='TMI' or
   (SELECT UPPER(gi_string1)
      FROM generalinfo
     WHERE gi_name = 'ImagingVendorInHouse')='TMI'
BEGIN
  --Create a cursor based on the select statement below
  DECLARE ordhdrnumber_cursor CURSOR FOR  
  SELECT ord_hdrnumber
    FROM orderheader 
   WHERE ord_hdrnumber <> 0 and
        (select DATEDIFF(day, ord_bookdate, getdate())) <= 90 
        and ord_status in ('DSP','PLN','STD','CMP','ICO','CAN')
  
  --Populate the cursor based on the select statement above  
  OPEN ordhdrnumber_cursor  
  
  --Execute the initial fetch of the first ord_hdrnumber
  FETCH NEXT FROM ordhdrnumber_cursor INTO @ord_hdrnumber 
  
  --If the fetch is succesful continue to loop
  WHILE @@fetch_status = 0  
  BEGIN  
 
   --Determine if the ord_hdrnumber exists in the ImageOrderList.db
   IF Not Exists (SELECT * 
                    FROM ImageOrderList 
                   WHERE ord_hdrnumber = @ord_hdrnumber)
   --If the ord_hdrnumber does not exists in the ImageOrderList.db,
   --then insert the ord_hdrnumber
   INSERT INTO ImageOrderList (ord_hdrnumber)VALUES(@ord_hdrnumber)

   --Fetch the next ord_hdrnumber in the list
   FETCH NEXT FROM ordhdrnumber_cursor INTO @ord_hdrnumber  
  
  END  
  --Close cursor  
  CLOSE ordhdrnumber_cursor
  --Release cusor resources  
  DEALLOCATE ordhdrnumber_cursor  
END  
  
GO
GRANT EXECUTE ON  [dbo].[TMI_imagingrecord_90DayHist] TO [public]
GO
