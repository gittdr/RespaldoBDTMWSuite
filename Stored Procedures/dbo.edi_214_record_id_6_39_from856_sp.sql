SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[edi_214_record_id_6_39_from856_sp]
	@p_trpid varchar(20),
	@p_docid varchar(30),
	@p_ordhdrnumber int,
	@p_statuscode varchar(2)
 as

 /**
 * 
 * NAME:
 * dbo.edi_214_record_id_6_39_from856_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Creates the OS&D or "6" record in the 214 flat file
 *
 *
 * RETURNS:
 * NONE
 *
 * RESULT SETS: 
 * NONE
 *
 * PARAMETERS:
 * 001 - @p_trpid, varchar(20), input, not null;
 *       This parameter indicates the trading partner ID 
 *       for which the 214 is being created . Must be
 *       non-null and non-empty.
 * 002 - @p_docid, varchar(30), input, notnull;
 *       This parameter indicates the document id 
 *       for the current 214 transaction. The value must be non-null and 
 *       non-empty.
 * 003 - @p_fgt_number, integer not null;
 *		 Parameter identifies the freight detail for which the OS&D record is being created.
 *		 Must be non-null and non-empty.
 *
 * REFERENCES: (called by and calling references only, don't 
 *              include table/view/object references)
 * Calls001    ? NONE
 * CalledBy001 ? edi_214_record_id_3_39_sp 
 * 
 * REVISION HISTORY:
 * 08/8/2005.01 ? PTS27619 - A. Rossman ? Changed procedure from a stub to implement new OS&D functionality in TMWSuite
 * 09/13/2005.02 - PTS 29718 - A.Rossman - Allow user to define a list of reference types to be appended to the end of the 
 *											record.  Only the first 15 characters of each ref. number will be used.
 * 7/19/2010.03 - PT 53249 - A.Rossman -  Fix to OSD calc for load event.
 **/

declare @esn_ident int
select @esn_ident = 0

if isnull(@p_ordhdrnumber,0) = 0 return 0

if (select count(*) from edi_856_shipment_notice where esn_tmw = @p_ordhdrnumber) > 0 
begin
	declare @rcvd_status varchar(60), @whse_status varchar(60), @dlvr_status varchar(60), @load_status varchar(60),
		@all_status varchar(243)
	
	select @rcvd_status = gi_string1, @whse_status = gi_string2, @dlvr_status = gi_string3, @load_status = gi_string4
	  from generalinfo where gi_name = 'EDI856_StatusCodes'
	
	select @all_status = isnull(@rcvd_status,'') + '|' + isnull(@whse_status,'') + '|' + isnull(@dlvr_status,'') + '|' + isnull(@load_status,'')
	
	--if CHARINDEX(@p_statuscode, @all_status) = 0 return 0
	if CHARINDEX(@p_statuscode, @all_status) > 0
	begin
		select @esn_ident = max(esn_identity)
		  from edi_856_shipment_notice
		 where esn_tmw = @p_ordhdrnumber
		
		declare @overage int, @shortage int, @damage int
		
		declare @details table
			(esd_cmd varchar(3), esd_ls varchar(30), esd_quantity int, esd_overage int, esd_shortage int, esd_damage int)
		
		if charindex(@p_statuscode, @rcvd_status) > 0
			insert @details
			select esd_cmd, esd_ls, esd_quantity, esd_rcvd_overage, esd_rcvd_shortage, esd_rcvd_damage
			  from edi_856_shipment_details
			 where esh_identity = @esn_ident
		
		if charindex(@p_statuscode, @whse_status) > 0
			insert @details
			select esd_cmd, esd_ls, esd_quantity, esd_whse_overage, esd_whse_shortage, esd_whse_damage
			  from edi_856_shipment_details
			 where esh_identity = @esn_ident
			   and esd_rcvd_overage + esd_rcvd_shortage + esd_rcvd_damage = 0

		if charindex(@p_statuscode, @load_status) > 0
			insert @details
			select esd_cmd, esd_ls, esd_quantity, esd_load_overage, esd_load_shortage, esd_load_damage
			  from edi_856_shipment_details
			 where esh_identity = @esn_ident
			   and esd_rcvd_overage + esd_rcvd_shortage + esd_rcvd_damage
			     + esd_whse_overage + esd_whse_shortage + esd_whse_damage = 0
		
		if charindex(@p_statuscode, @dlvr_status) > 0
			insert @details
			select esd_cmd, esd_ls, esd_quantity, esd_dlvr_overage, esd_dlvr_shortage, esd_dlvr_damage
			  from edi_856_shipment_details
			 where esh_identity = @esn_ident
			   and esd_rcvd_overage + esd_rcvd_shortage + esd_rcvd_damage
			     + esd_whse_overage + esd_whse_shortage + esd_whse_damage
			     + esd_load_overage + esd_load_shortage + esd_load_damage = 0
		
		select	@overage = sum(esd_overage),
			@shortage = sum(esd_shortage),
			@damage = sum(esd_damage)
		  from	@details
		
		if @overage > 0
		begin
			insert edi_214 (data_col,trp_id,doc_id)
			values ('639O   ' + right('000000' + convert(varchar,@overage), 6), @p_trpid, @p_docid)
		
			insert edi_214 (data_col,trp_id,doc_id)
			select '439REFMC ' + esd_ls, @p_trpid, @p_docid
			  from @details
			 where esd_overage > 0
			 order by esd_ls
		end
		
		if @shortage > 0
		begin
			insert edi_214 (data_col,trp_id,doc_id)
			values ('639P   ' + right('000000' + convert(varchar,@shortage), 6), @p_trpid, @p_docid)
		
			insert edi_214 (data_col,trp_id,doc_id)
			select '439REFMC ' + esd_ls, @p_trpid, @p_docid
			  from @details
			 where esd_shortage > 0
			 order by esd_ls
		end
		
		
		if @damage > 0
		begin
			insert edi_214 (data_col,trp_id,doc_id)
			values ('639D   ' + right('000000' + convert(varchar,@damage), 6), @p_trpid, @p_docid)
		
			insert edi_214 (data_col,trp_id,doc_id)
			select '439REFMC ' + esd_ls, @p_trpid, @p_docid
			  from @details
			 where esd_damage > 0
			 order by esd_ls
		end
	end
end

insert edi_214 (data_col,trp_id,doc_id)
values ('639    000000', @p_trpid, @p_docid)

return @esn_ident
GO
GRANT EXECUTE ON  [dbo].[edi_214_record_id_6_39_from856_sp] TO [public]
GO
