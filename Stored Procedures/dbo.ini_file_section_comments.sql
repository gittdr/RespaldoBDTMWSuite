SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 CREATE PROCEDURE [dbo].[ini_file_section_comments]
AS
/************************************************************************************
 NAME:	    ini_file_section_comments
 TYPE:	    stored procedure
 DATABASE:	TMW
 PURPOSE:   Get the comments for the file/section
 RETRUNS:


REVISION LOG

DATE		  WHO			  REASON
----		  ---			  ------
08-Feb-02    Tannis Drysdale    Created
27-Mar-02    Tannis Drysdale    Fix permissions
09-Apr-02    Tannis Drysdale    Format as per QA guidelines
Nov-01-2007  MROIK              PTS # 38837 - Migrated from Sybase to MS SQL Server

EXEC ini_file_section_comments
*************************************************************************************/

select f.file_id,
       f.file_name,
       s.section_id,
       s.section_name,
       x.comment,
       x.file_section_id
from ini_file f
     inner join ini_xref_file_section x
        on x.file_id = f.file_id
     inner join ini_section s
        on x.section_id = s.section_id



GO
GRANT EXECUTE ON  [dbo].[ini_file_section_comments] TO [public]
GO
