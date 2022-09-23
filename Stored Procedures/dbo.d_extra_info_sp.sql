SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*   MODIFICATIONS  
DPETE PTS 12841 provide validation for data  

PTS 21442 - KWS Added if exists statement to prevent blank rows  
 * 10/26/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
*/  
CREATE PROCEDURE [dbo].[d_extra_info_sp]  
@extra_id int,  
@tab_id int,  
@table_key varchar(50)  
AS  
-- This will create the result set for datawindow d_extra_info.  
  
DECLARE @counter int  
DECLARE @max_row int  
  
SET @counter = 1  
  
CREATE TABLE #out_data 
  (tab_id int,   
   col_id int,   
   col_name varchar(50),   
   editable char(1) NULL,   
   ddlb varchar(255) NULL,  
   mask varchar(128) NULL,  
   mask_type char(1) NULL,  
   extra_id int,  
   display_order int NULL,  
   label   varchar(128) null,  
   format  varchar(128) null,  
   col_data varchar(7665) NULL,  
   table_key varchar(50) NULL,  
   col_row int NULL,  
   does_exist char(1),  
   expression varchar(120) NULL,  
   err_msg varchar(120) NULL, 
   col_datetime datetime NULL, 
   col_number decimal(12, 4) NULL,
   masterfile varchar(12) NULL)  
-- The does_exist is used to determine if this row exists in the database  
-- for later use in the application.  

SELECT @max_row = MAX( col_row ) FROM EXTRA_INFO_DATA   
 WHERE @extra_id = EXTRA_ID AND @tab_id = TAB_ID AND @table_key = TABLE_KEY  
  
WHILE @counter < @max_row + 1  
 BEGIN  
   IF (EXISTS (select * FROM EXTRA_INFO_COLS C, EXTRA_INFO_DATA D  
       WHERE C.COL_ID = D.COL_ID AND D.COL_ROW = @counter AND  
       C.EXTRA_ID = @extra_id AND C.TAB_ID = @tab_id AND D.TABLE_KEY = @table_key))
       INSERT INTO #out_data   
	 SELECT C.TAB_ID,     
	  C.COL_ID,     
	  C.COL_NAME,     
	  IsNULL( C.EDITABLE, 'N'),  
	  C.DDLB,     
	  C.MASK,     
	  C.MASK_TYPE,  
	  C.EXTRA_ID,     
	  C.DISPLAY_ORDER,  
	  c.label,  
	  c.format,     
	  SUBSTRING(D.COL_DATA, 1, 7665),     
	  IsNull( D.TABLE_KEY, @table_key ),  
	  IsNull( D.COL_ROW, @counter ),  
	  CASE when D.COL_ID is null  THEN 'N' ELSE 'Y' END,  
	  IsNull(expression,''), 
	  IsNull(err_msg,''), 
	  col_datetime, 
	  col_number, 
	  C.MASTERFILE   
	FROM  EXTRA_INFO_COLS C  LEFT OUTER JOIN  EXTRA_INFO_DATA D  ON  (C.COL_ID  = D.COL_ID and D.TABLE_KEY  = @table_key and D.COL_ROW  = @counter)
	WHERE	C.EXTRA_ID  = @extra_id
	 AND	C.TAB_ID  = @tab_id	
	ORDER BY C.DISPLAY_ORDER ASC 
   
   SET @counter = @counter + 1  
END  

SELECT tab_id, 
       col_id, 
       col_name, 
       editable, 
       ddlb, 
       mask, 
       mask_type, 
       extra_id, 
       display_order, 
       label, 
       format, 
       col_data, 
       table_key, 
       col_row, 
       does_exist, 
       expression, 
       err_msg, 
       col_datetime, 
       col_number, 
       masterfile, 
       col_datetime col_date, 
       col_datetime col_time  
  FROM #out_data  

GO
GRANT EXECUTE ON  [dbo].[d_extra_info_sp] TO [public]
GO
