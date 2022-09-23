SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.pb_catcol    Script Date: 6/1/99 11:54:37 AM ******/
create procedure [dbo].[pb_catcol] @tblobjid int, @colobjid smallint as 
select pbc_labl, pbc_lpos, pbc_hdr, pbc_hpos,  		 pbc_jtfy, pbc_mask, pbc_case, pbc_hght, pbc_wdth, 
pbc_ptrn, pbc_bmap, pbc_cmnt, pbc_init, pbc_edit 
from dbo.pbcatcol where pbc_tid = @tblobjid and 
pbc_cid = @colobjid 





GO
GRANT EXECUTE ON  [dbo].[pb_catcol] TO [public]
GO
