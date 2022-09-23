SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[dedicated_allocation_invoice_detail] @ivh_hdrnumber INT,  
                                                         @ord_hdrnumber INT,  
                                                         @cht_itemcode VARCHAR(6),  
                                                         @tar_number INT,  
                                                         @quantity FLOAT,  
                                                         @rate  MONEY,  
                                                         @charge MONEY,  
                                                         @desc  VARCHAR(50),  
                                                         @ivd_number INT,  
                                                         @ivd_allocation_type varchar (6) /*PTS 53514*/  
AS  
DECLARE @newivdnum INT,  
        @nextsequence INT,  
        @cht_basisunit VARCHAR(6),  
        @cht_unit VARCHAR(6),  
        @cht_taxtable1  CHAR(1),  
        @cht_taxtable2 CHAR(1),  
        @cht_taxtable3 CHAR(1),  
        @cht_taxtable4 CHAR(1),  
        @cht_lh_min CHAR(1),  
        @cht_lh_rpt CHAR(1),  
        @cht_lh_rev CHAR(1),  
        @cht_lh_stl CHAR(1),  
        @cht_rollintolh INT,  
        @cht_class VARCHAR(6),  
        @cht_glnum CHAR(32),  
        @cht_sign SMALLINT,  
				@billto  VARCHAR(8) ,
				@definition varchar(6), --PTS 53507 SGB  
				@tar_tariffnumber varchar(12)
  
EXEC @newivdnum = getsystemnumber 'INVDET', ''  
  
SELECT @nextsequence = MAX(ivd_sequence) + 1  
  FROM invoicedetail  
 WHERE ivh_hdrnumber = @ivh_hdrnumber  
  
SELECT @billto = ivh_billto,
						@definition = ivh_definition --PTS 53507 SGB
  FROM invoiceheader  
 WHERE ivh_hdrnumber = @ivh_hdrnumber  

--PTS 53507 SGB If Credit Memo do not add Allocation
IF  @definition = 'CRD' 
	BEGIN
		RETURN
	END
	
  
SELECT @cht_basisunit = cht_basisunit,  
       @cht_unit = cht_unit,  
       @cht_taxtable1 = cht_taxtable1,  
       @cht_taxtable2 = cht_taxtable2,  
       @cht_taxtable3 = cht_taxtable3,  
       @cht_taxtable4 = cht_taxtable4,  
       @cht_lh_min = cht_lh_min,  
       @cht_lh_rpt = cht_lh_rpt,  
       @cht_lh_rev = cht_lh_rev,  
       @cht_lh_stl = cht_lh_stl,  
       @cht_rollintolh = cht_rollintolh,  
       @cht_class = cht_class,  
       @cht_glnum = cht_glnum,  
       @cht_sign = cht_sign  
  FROM chargetype  
 WHERE cht_itemcode = @cht_itemcode  

Select @tar_tariffnumber = tar_tarriffnumber
from tariffheader
where tar_number = @tar_number 
  
INSERT INTO invoicedetail (ivd_number, ivd_sequence, ivh_hdrnumber, ord_hdrnumber, --1  
                           ivd_billto, cht_itemcode, ivd_description, ivd_type,  --2  
                           cht_basisunit, ivd_unit, ivd_taxable1, ivd_taxable2,  --3  
                           ivd_taxable3, ivd_taxable4, cht_lh_min, cht_lh_rev,  --4   
                           cht_lh_rpt, cht_lh_stl, cht_rollintolh, cht_class,  --5  
                           ivd_glnum, ivd_sign, cmp_id, cmd_code, fgt_supplier,  --6  
                           ivd_distance, ivd_wgt, ivd_count, ivd_volume,  --7  
                           ivd_quantity_type, ivd_charge_type, ivd_rate_type,  --8  
                           ivd_itemquantity, ivd_subtotalptr, ivd_ordered_count, --9  
                           ivd_ordered_loadingmeters, ivd_ordered_volume,  --10   
                           ivd_ordered_weight, ivd_loadingmeters, ivd_loaded_distance, --11  
                           ivd_empty_distance, ivd_MaskFromRating, ivd_quantity, --12  
                           ivd_rate, ivd_charge, ivd_allocated_ivd_number, ivd_allocation_type, /*PTS 53514*/   --13   
                           tar_number,tar_tariffnumber,ivd_fromord) /*PTS 54812*/ --14
                   VALUES (@newivdnum, @nextsequence, @ivh_hdrnumber, @ord_hdrnumber, --1  
                           @billto, @cht_itemcode, @desc, 'LI',    --2  
                           @cht_basisunit, @cht_unit, @cht_taxtable1, @cht_taxtable2, --3  
                           @cht_taxtable3, @cht_taxtable4, @cht_lh_min, @cht_lh_rev, --4  
                           @cht_lh_rpt, @cht_lh_stl, @cht_rollintolh, @cht_class, --5  
                           @cht_glnum, @cht_sign, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', --6  
                           0, 0, 0, 0,       --7  
                           0, 0, 0,       --8  
                           0, 0, 0,       --9  
                           0, 0,       --10  
                           0, 0, 0,       --11  
             0, 'N', @quantity,      --12  
                           @rate, @charge, @ivd_number, @ivd_allocation_type, /*PTS 53514*/     --13  
                           @tar_number,@tar_tariffnumber,'A')  /*PTS 54812*/ --14
  
  
UPDATE invoiceheader  
   SET ivh_totalcharge = (SELECT SUM(ivd_charge)  
                            FROM invoicedetail  
                           WHERE ivh_hdrnumber = @ivh_hdrnumber)  
 WHERE ivh_hdrnumber = @ivh_hdrnumber  

GO
GRANT EXECUTE ON  [dbo].[dedicated_allocation_invoice_detail] TO [public]
GO
