SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[update_ord_copied_from] 
    @orig_ord_hdrnumber int, 
    @master_ord_hdrnumber int
AS

/************************************************************************************
 NAME:	          update_ord_copied_from
 DOS NAME:	  tmwsp_update_ord_copied_from.sql 
 TYPE:		  stored procedure
 DATABASE:	  TMW
 PURPOSE:	  Update order with new copied from information
 DEPENDANCIES:


REVISION LOG

DATE		WHO	                REASON
----		---	                ------
27-Sep-07       RHING                   Created, adapted from FSS
12-nov-07	kdecelle		Updated to remove unnecesary code.
exec update_ord_copied_from 2777866, 0

*************************************************************************************/

declare @orig_copied_from int,
        @error int,
        @ret int

--Initialize return value
select @ret = 1

select @orig_copied_from = ord_fromorder
from orderheader
where ord_hdrnumber = @orig_ord_hdrnumber

if (@orig_copied_from <> @master_ord_hdrnumber)  and (@master_ord_hdrnumber >= 0)
  begin

    begin tran orderHeaderUpdate

    UPDATE orderheader
    set ord_fromorder = @master_ord_hdrnumber
    where ord_hdrnumber = @orig_ord_hdrnumber

    /* ADD ERROR CHECKING */
    select @error = @@error
    if @error <> 0
    begin
        Rollback tran orderHeaderUpdate
        select @ret = 0
    end
    else
    begin
        commit tran orderHeaderUpdate
        select @ret = 1
    end
  end

return @ret
GO
GRANT EXECUTE ON  [dbo].[update_ord_copied_from] TO [public]
GO
