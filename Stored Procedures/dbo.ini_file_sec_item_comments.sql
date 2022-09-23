SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 CREATE PROCEDURE [dbo].[ini_file_sec_item_comments]
AS
/************************************************************************************
 NAME:	    ini_file_sec_item_comments
 TYPE:	    stored procedure
 DATABASE:	TMW
 PURPOSE:   Get the comments for the file/section/item
 RETRUNS:


REVISION LOG

DATE		  WHO			      REASON
----		  ---			      ------
08-Feb-02    Tannis Drysdale      Created
27-Mar-02    Tannis Drysdale      Permissions granted   
09-Apr-02    Tannis Drysdale      Formatting as per QA guidelines
Nov-01-2007  MROIK                PTS # 38837 - Migrated from Sybase to MS SQL Server

EXEC ini_file_sec_item_comments 
*************************************************************************************/

select f.file_id, 
       f.file_name,
       s.section_id,
       s.section_name,
       i.item_id,
       i.item_name,
       xfsi.comment,
       xfsi.file_section_item_id
from ini_file f
     inner join ini_xref_file_section xfs
        on f.file_id=xfs.file_id
     inner join ini_xref_file_section_item xfsi
        on xfs.file_section_id = xfsi.file_section_id
     inner join ini_section s
        on xfs.section_id = s.section_id
     inner join ini_item i 
        on xfsi.item_id = i.item_id




GO
GRANT EXECUTE ON  [dbo].[ini_file_sec_item_comments] TO [public]
GO
