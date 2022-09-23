SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/*

   This procedure is used by Pegasus Imaging Software company to update the pegasus_invoicelist table of 
   imaged documents witht he status (S for success , F for Failure) of their processing.
PTS15913 DPETE created 10/24/02 for Pegasus Imaging
*/

CREATE PROC [dbo].[SetImageStatus](@tiffname varchar(20),@status char(1), @msg varchar(254) )
AS
Declare @ivhnbr int
If @msg Is Null Select @msg = ''

Select @ivhnbr = Min(ivh_hdrnumber) from pegasus_invoicelist
Where peg_controlnumber = @tiffname

While @ivhnbr is not null
  Begin
    -- done one record at a time to accommodate trigger
    Update pegasus_invoicelist set peg_status = Case Upper(@status) When 'S' Then 3 When 'F' Then 2 Else peg_status End,
    peg_dateprocessed = getdate(), peg_statusmsg = @msg
    Where peg_controlnumber = @tiffname and ivh_hdrnumber = @ivhnbr

    Select @ivhnbr = Min(ivh_hdrnumber) from pegasus_invoicelist
    Where peg_controlnumber = @tiffname and ivh_hdrnumber > @ivhnbr
  End

GO
GRANT EXECUTE ON  [dbo].[SetImageStatus] TO [public]
GO
