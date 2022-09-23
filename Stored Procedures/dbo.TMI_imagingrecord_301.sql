SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/*
Created for TMI on PTS 15477
Example call 
exec TMI_imagingrecord_301 'DET1',1,'A'
exec tmi_imagingrecord_301 'UNKNOWN',1,'L'  
These records are to be created when records are added to or deleted from the billdoctypes table


*/
Create Procedure [dbo].[TMI_imagingrecord_301]  @billto Varchar(8),@seq tinyint, @transcode char(1)
As

--DTS when sql returns messages due to inserts
SET NOCOUNT ON

If @transcode = 'L'
   Select '30102'
  +@transcode
  +Convert(char(10),cmp_id)
  +Convert(char(10),bdt_doctype)
  From billdoctypes 
Else
  Select '30102'
  +@transcode
  +Convert(char(10),@billto)
  +Convert(char(10),bdt_doctype)
  From billdoctypes Where cmp_id = @billto and bdt_sequence = @seq
GO
GRANT EXECUTE ON  [dbo].[TMI_imagingrecord_301] TO [public]
GO
