SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROC [dbo].[d_load_masterordernumber_bestmatch_sp] @MST_ord_number varchar(12), @number int 

AS  
--  ord_number is currently varchar(12)
--  ord_status is currently varchar(6)  

-- Created for PTS 49110  9/25/2009
				-- original dddw select was...
				--  select ord_number
				--  from orderheader
				--  where  ord_status='MST'
				--  order by ord_number
				
--  PTS 61996 5/2/2013; ord_status='MST' went mia.  put it back.
 
if @number = 1   
 set rowcount 1   
else if @number <= 8   
 set rowcount 8  
else if @number <= 16  
 set rowcount 16  
else if @number <= 24  
 set rowcount 24  
else  
 set rowcount 8  
  
if exists (SELECT ord_number  
		   FROM orderheader   
		   WHERE  ord_status='MST' And ord_number LIKE @MST_ord_number + '%' )  
  
		   SELECT orderheader.ord_number  
		   FROM orderheader   
		   WHERE  ord_status='MST' And ord_number LIKE @MST_ord_number + '%'     
		   ORDER by ord_number 
Else  
SELECT 'UNKNOWN' as 'ord_number'     
 set rowcount 0   

GO
GRANT EXECUTE ON  [dbo].[d_load_masterordernumber_bestmatch_sp] TO [public]
GO
