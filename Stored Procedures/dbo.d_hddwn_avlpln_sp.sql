SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_hddwn_avlpln_sp    Script Date: 6/1/99 11:54:12 AM ******/
--create stored procedure 
CREATE PROC [dbo].[d_hddwn_avlpln_sp](@v_legnumber int)
                                 

AS

--*********************************************************************************************
--Declaration and initialization of variables

DECLARE @mov_number  int,
        @char1       Varchar(8),
        @char2       int,
        @rscrs_drv1  Varchar(8),
        @rscrs_drv2  Varchar(8),
        @rscrs_car   Varchar(8)
	
--*********************************************************************************************
--Create temporary waybill table for Printing of waybills process
update legheader
   set lgh_outstatus = 'PLN'
 where lgh_number = @v_legnumber  

GO
GRANT EXECUTE ON  [dbo].[d_hddwn_avlpln_sp] TO [public]
GO
