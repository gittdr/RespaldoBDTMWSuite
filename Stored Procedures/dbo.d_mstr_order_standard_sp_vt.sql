SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_mstr_order_standard_sp_vt]
                  @stringparm   varchar(12),
                  @numberparm           int,
                  @retrieve_by   varchar(8) AS

BEGIN
/************************************************************************************
 NAME:		d_mstr_order_standard_sp_vt
 DOS NAME:	tmwsp_d_mstr_order_standard_sp_vt.sql
 TYPE:		stored procedure
 DATABASE:	TMW
 PURPOSE:
 DEPENDANCIES:
 PROCESS:
 ---------------------------------------------------------------------------
				CONFIDENTIAL AND PROPRIETARY
				COPYRIGHT 1998 MBI DATA SERVICES LTD
				ALL RIGHTS RESERVED
 ---------------------------------------------------------------------------
REVISION LOG

DATE			WHO				REASON
----			---				------

1999-06-14      Neil Mehta      Added three new columns to the result set (driver_pay_pct,
                                leasedop_pay_pct and revenue_amt).
2000-04-11      Odette Roy      Addded 4 fields: EPM, EPH, GVW, Comments
*************************************************************************************/
IF NOT EXISTS (SELECT 1 FROM orderheader where ord_hdrnumber = @numberparm and ord_status = 'MST')
BEGIN
    -- changed from the Trimac field ord_copied_from to the TMW field ord_fromorder
    -- Pts 14071 - DJM - Modified to allow for an Order Number in the ord_fromorder field.
    SELECT @numberparm = ord2.ord_hdrnumber 
    FROM    orderheader ord1, orderheader ord2
    WHERE   ord1.ord_hdrnumber = @numberparm and
	ord2.ord_number = ord1.ord_fromorder
END

SELECT masterorders_ref.ord_hdrnumber ,
       masterorders_ref.master_refnumber ,
       masterorders_ref.ord_revtype1 , 	
       masterorders_ref.ord_loadtime ,
       masterorders_ref.ord_unloadtime ,
       masterorders_ref.ord_totaltime ,
       masterorders_ref.productive_hrs ,
       masterorders_ref.payload_value ,
       masterorders_ref.payload_uom ,
       masterorders_ref.cleaning_costs ,
       masterorders_ref.permits_toll_costs ,
       masterorders_ref.loaded_miles ,
       masterorders_ref.unloaded_miles,
       masterorders_ref.driver_pay_pct,
       masterorders_ref.leasedop_pay_pct,
       masterorders_ref.revenue_amt,
       masterorders_ref.epm,
       masterorders_ref.eph,
       masterorders_ref.gvw,
       masterorders_ref.comments
  FROM masterorders_ref
 WHERE masterorders_ref.ord_hdrnumber = @numberparm

END
GO
GRANT EXECUTE ON  [dbo].[d_mstr_order_standard_sp_vt] TO [public]
GO
