SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
/*

   This procedure is used by Pegasus Imaging Software company to add records to a table of images they received, but 
   could not process (tiff name is not a valid control number in the pegasus_invoiclist table.).

PTS15913 DPETE created 10/24/02 for Pegasus Imaging
*/

CREATE PROC [dbo].[AddImageUnexpected] (@msg varchar(254) )
AS
If @msg is not null and Datalength(Rtrim(@msg)) > 0
  Insert Into ImageUnexpected (iu_date,iu_msg) Values (getdate(),@msg)

GO
GRANT EXECUTE ON  [dbo].[AddImageUnexpected] TO [public]
GO
