SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE  [dbo].[sp_DXArchive_GetValidations]
@ord_hdrnumber int = 0,
@FromDate datetime = null,
@ToDate datetime = null
As

declare @v_displaydecisionsonly char(1)
SELECT  @v_displaydecisionsonly = isnull(gi_string1,'N')
  FROM  generalinfo
 WHERE  gi_name = 'LTSLWrkshtOverrides'


declare @validations table (
		[ident] int identity not null,
		[dx_sourcedate] [datetime] NOT NULL ,
		[dx_ordernumber] varchar(30) NOT NULL,
		 [firststopseq] int,
		 [laststopseq] int,
		 ProcessType varchar(8),
		 esc_description varchar(255),
		 ord_editradingpartner varchar(255),
		 ord_number varchar(12),
		 ord_status varchar(6),
		 ord_revtype1 varchar(6),
		 ord_revtype2 varchar(6),
		 ord_revtype3 varchar(6),
		 ord_revtype4 varchar(6),
		 ord_startdate datetime,
		 ord_hdrnumber int,
		 ord_edistate smallint,
		 ord_billto varchar(8)
		)

insert into @validations (dx_sourcedate,dx_ordernumber,firststopseq,laststopseq,ProcessType)
	select dx_sourcedate, dx_ordernumber, min(dx_seq), max(dx_seq), 'Match'
	from dx_Archive_header dh (nolock)
	join dx_archive_detail dd (nolock) on dh.dx_Archive_header_id = dd.dx_Archive_header_id
	where dx_processed = 'DIVERT'
	and dx_field001 = '06'
	and dx_field003 = 'ST'
	and not exists(select 1 from referencenumber join orderheader on referencenumber.ord_hdrnumber = orderheader.ord_hdrnumber	
					where ref_type = 'SID' and ref_number = dx_ordernumber and ord_editradingpartner = dx_trpid)
	and not exists(select 1 from dx_archive_header d1 where dh.dx_ordernumber = d1.dx_ordernumber and dh.dx_trpid = d1.dx_trpid and d1.dx_processed = 'QUEUED')
	and (@ord_hdrnumber = 0 or dh.dx_orderhdrnumber = @ord_hdrnumber)
	and (@FromDate is null or @ToDate is null or dh.dx_sourcedate >= @FromDate and dh.dx_sourcedate <= @ToDate)
	group by dx_ordernumber,dx_sourcedate having min(dh.dx_sourcedate) = (select min(dx_sourcedate) 
									from dx_archive_header dh1 
									join dx_archive_detail dd1 (nolock) on dh1.dx_Archive_header_id = dd1.dx_Archive_header_id
									where dh.dx_ordernumber = dh1.dx_ordernumber
									and dh1.dx_processed = 'DIVERT'
									and dd1.dx_field001 = '06'
									and dd1.dx_field003 = 'ST'
									and not exists(select 1 from referencenumber join orderheader on referencenumber.ord_hdrnumber = orderheader.ord_hdrnumber	
												where ref_type = 'SID' and ref_number = dx_ordernumber and ord_editradingpartner = dx_trpid))

insert into @validations (dx_sourcedate,dx_ordernumber,firststopseq,laststopseq,ProcessType, esc_description,
			ord_editradingpartner, ord_number, ord_status, ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4, ord_startdate,
			ord_hdrnumber, ord_edistate, ord_billto)
	select min(dx_sourcedate), dx_ordernumber, min(dx_seq), max(dx_seq) , 'Validate', max(esc_description), 
			max(ord_editradingpartner), max(ord_number), max(ord_status), max(ord_revtype1), max(ord_revtype2), max(ord_revtype3), max(ord_revtype4), 
			max(ord_startdate), max(ord_hdrnumber), max(ord_edistate), max(ord_billto)
	from dx_Archive_header dh (nolock)
	join dx_archive_detail dd (nolock) on dh.dx_Archive_header_id = dd.dx_Archive_header_id
	join orderheader o (nolock) on o.ord_hdrnumber = dh.dx_orderhdrnumber
	left join edi_orderstate e (nolock) on e.esc_code = o.ord_edistate
	where dx_processed = 'WAIT'
	and dx_field001 = '06'
	and dx_field003 = 'ST'
	and dx_orderhdrnumber > 0
	and (@ord_hdrnumber = 0 or dh.dx_orderhdrnumber = @ord_hdrnumber)
	and (@FromDate is null or @ToDate is null or dh.dx_sourcedate >= @FromDate and dh.dx_sourcedate <= @ToDate)
	group by dx_ordernumber, dx_sourcedate
	having min(dx_sourcedate) = (select min(dx_sourcedate) from dx_archive_header dh1 
															join dx_archive_detail dd1 (nolock) on dh1.dx_Archive_header_id = dd1.dx_Archive_header_id
									where dh.dx_ordernumber = dh1.dx_ordernumber
									and dh1.dx_processed = 'WAIT'
									and dd1.dx_field001 = '06'
									and dd1.dx_field003 = 'ST'
									and dh1.dx_orderhdrnumber > 0)
declare @Use204Validation int
declare @UseMaritimeValidation int
exec @Use204Validation = dx_GetLTSL2Setting 'UpdateValidation'
exec @UseMaritimeValidation = dx_GetLTSL2Setting 'MaritimeValidation'


if @Use204Validation = 1 or @UseMaritimeValidation = 1
	insert into @validations (dx_sourcedate,dx_ordernumber,firststopseq,laststopseq,ProcessType, esc_description,
				ord_editradingpartner, ord_number, ord_status, ord_revtype1, ord_revtype2, ord_revtype3, ord_revtype4, ord_startdate,
				ord_hdrnumber, ord_edistate, ord_billto)
		select dx_sourcedate, dx_ordernumber, min(dx_seq), max(dx_seq) , 'Resubmit', max(esc_description), 
				max(ord_editradingpartner), max(ord_number), max(ord_status), max(ord_revtype1), max(ord_revtype2), max(ord_revtype3), max(ord_revtype4),
				max(ord_startdate), max(ord_hdrnumber), max(ord_edistate), max(ord_billto)
		from dx_Archive_header dh (nolock)
		join dx_archive_detail dd (nolock) on dh.dx_Archive_header_id = dd.dx_Archive_header_id
		join orderheader o (nolock) on o.ord_hdrnumber = dh.dx_orderhdrnumber
		left join edi_orderstate e (nolock) on e.esc_code = o.ord_edistate
		LEFT JOIN dx_xref x on x.dx_trpid = o.ord_editradingpartner and dx_entitytype = 'TPSettings' and dx_entityname = 'NoMaritimeQueProcessing'

		where (dx_processed = 'DONE')
		and dx_field001 = '06' and dx_field003 = 'ST'
		and dx_orderhdrnumber > 0
		and o.ord_order_source = 'EDI' 
		and o.ord_status IN ('PND', 'AVL', 'DSP', 'PLN', 'STD', 'MPN', 'CAN', 'ICO')
		and (@Use204Validation = 1 or (@UseMaritimeValidation = 1 and IsNull(x.dx_xrefkey, 0) = 0 and o.ord_edistate not in (40,41,42,43,45)))
		and e.esc_useractionrequired = 'Y' 
		and o.ord_edistate in (40,41,42,43,45)
		and (@ord_hdrnumber = 0 or dh.dx_orderhdrnumber = @ord_hdrnumber)
		and (@FromDate is null or @ToDate is null or dh.dx_sourcedate >= @FromDate and dh.dx_sourcedate <= @ToDate)
		group by dx_ordernumber, dx_sourcedate, dx_orderhdrnumber
		having max(dh.dx_sourcedate) = (select max(dx_sourcedate) from dx_archive_header d1 
										where dh.dx_ordernumber = d1.dx_ordernumber 
										and d1.dx_processed = 'DONE' 
										and d1.dx_orderhdrnumber = dh.dx_orderhdrnumber)
	
	select dxad.dx_ident, ProcessType, dxah.dx_ordernumber as SID, IsNull(dxah.dx_trpid, ord_editradingpartner) as TradingPartner, IsNull(dxah.dx_billto,ord_billto) as BillTo,
			IsNull(dxah.dx_sourcedate_reference,dxah.dx_sourcedate) as SourceDate, dxad.dx_field004 as Purpose, esc_description as EdiStateDesc, 
			ord_number as OrderNumber, ord_status as OrderStatus, ord_revtype1 as RevType1, ord_revtype2 as RevType2, ord_revtype3 as RevType3, ord_revtype4 as RevType4, 
			ord_startdate as OrderStartDate, ord_hdrnumber as OrderHeaderNumber, ord_edistate as EDIState,
			dxbd.dx_field004 as OriginName, dxbd.dx_field005 as OriginAddress, 
			dxbd.dx_field007 as OriginCity, dxbd.dx_field008 as OriginState, dxbd.dx_field009 as OriginZip,
			dxcd.dx_field004 as DestinationName, dxcd.dx_field005 as DestinationAddress, 
			dxcd.dx_field007 as DestinationCity, dxcd.dx_field008 as DestinationState, dxcd.dx_field009 as DestinationZip
 from @validations vld
  join dx_archive_header dxah (nolock) on vld.dx_sourcedate = dxah.dx_sourcedate 
  join dx_archive_detail dxad (nolock) on dxah.dx_Archive_header_id = dxad.dx_Archive_header_id and dxad.dx_field001 = '02'
   join dx_archive_header dxbh (nolock) on vld.dx_sourcedate = dxbh.dx_sourcedate 
   join dx_archive_detail dxbd (nolock) on dxbh.dx_Archive_header_id = dxbd.dx_Archive_header_id and dxbd.dx_field001 = '06' and dxbd.dx_seq = vld.firststopseq
   join dx_archive_header dxch (nolock) on vld.dx_sourcedate = dxch.dx_sourcedate 
   join dx_archive_detail dxcd (nolock) on dxch.dx_Archive_header_id = dxcd.dx_Archive_header_id and dxcd.dx_field001 = '06' and dxcd.dx_seq = vld.laststopseq
	order by dxah.dx_sourcedate

GO
GRANT EXECUTE ON  [dbo].[sp_DXArchive_GetValidations] TO [public]
GO
