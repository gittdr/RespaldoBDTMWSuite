SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_214_record_id_4_39_from856_sp]
	@esn_ident int,
	@cmd_code varchar(8),
	@trpid varchar(20), 
	@docid varchar(30)

 as

  /**
 * 
 * NAME:
 * dbo.edi_214_record_id_4_39_from856_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * This procedure creates the miscellaneous "4" records for the EDI 214 document.  
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * none.
 *
 * PARAMETERS:
 * 001 - @ord_hdrnumber, integer, input, null;
 *       This parameter indicates the invoice number for which the records are being created.
 * 002 - @table, varchar(20), input, null;
 *       This parameter indicates the type pof reference number for which the record is being created.
 * 003 - @trpid, varchar(20), input, null;
 *       This parameter indicates the trading partner for which the EDI 214 is being
 *       created.
 * 004 - @docid, varchar(30), input, null;
 *		 This parameter indicates the document id for the individual edi 214 transaction.
 * 005 - @company_id varchar(8), input null;
 *	     This parameter indicates the company id for which the reference record is being created.
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * CalledBy001 ? edi_214_record_id_1_39_sp
 * CalledBy002 ? edi_214_record_id_3_39_sp

 * 
 * REVISION HISTORY:
 *
 **/

insert edi_214 (data_col,trp_id,doc_id)
select '439REFMC ' + esd_ls, @trpid, @docid
  from edi_856_shipment_details
 where esh_identity = @esn_ident
   and esd_cmd = @cmd_code
   and esd_rcvd_overage + esd_rcvd_shortage + esd_rcvd_damage 
     + esd_whse_overage + esd_whse_shortage + esd_whse_damage
     + esd_load_overage + esd_load_shortage + esd_load_damage
     + esd_dlvr_overage + esd_dlvr_shortage + esd_dlvr_damage = 0
 order by esd_ls


GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_4_39_from856_sp] TO [public]
GO
