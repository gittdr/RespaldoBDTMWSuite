SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE  proc [dbo].[dx_report_EDIOrder]
	@ord_number varchar(12)
as

declare @ordhdr int, @sourcedate datetime

declare @archive table
	(dx_seq int NOT NULL, 
	 dx_accepted bit NULL, 
	 dx_orderhdrnumber int NULL, 
	 dx_stopnumber int NULL,
	 dx_freightnumber int NULL, 
	 dx_field001 varchar(200) NULL, 
	 dx_field002 varchar(200) NULL,
	 dx_field003 varchar(200) NULL,
	 dx_field004 varchar(200) NULL,
	 dx_field005 varchar(200) NULL,
	 dx_field006 varchar(200) NULL,
	 dx_field007 varchar(200) NULL,
	 dx_field008 varchar(200) NULL,
	 dx_field009 varchar(200) NULL,
	 dx_field010 varchar(200) NULL,
	 dx_field011 varchar(200) NULL, 
	 dx_field012 varchar(200) NULL,
	 dx_field013 varchar(200) NULL,
	 dx_field014 varchar(200) NULL,
	 dx_field015 varchar(200) NULL,
	 dx_field016 varchar(200) NULL,
	 PRIMARY KEY (dx_seq))

declare @ediorder table
	(ident int IDENTITY,
	 dx_orderhdrnumber int,
	 dx_sourcedate datetime,
	 dx_hdr_accepted bit,
	 dx_hdr_isagsid varchar(14),
	 dx_hdr_purpose varchar(1),
	 dx_hdr_ordernumber varchar(20),
	 dx_hdr_bookdate varchar(12),
	 dx_hdr_startdate varchar(12),
	 dx_hdr_enddate varchar(12),
	 dx_hdr_paymentmethod varchar(2),
	 dx_hdr_totalchargecurrency varchar(1),
	 dx_hdr_totalcharge varchar(12),
	 dx_hdr_totalweight varchar(12),
	 dx_hdr_totalmiles varchar(12),
	 dx_hdr_totalpieces varchar(12),
	 dx_hdr_edicontrolnumber varchar(9),
	 dx_hdr_shipmentnumber varchar(30),
	 dx_shp_companyname varchar(35),
	 dx_shp_companyaddress1 varchar(35),
	 dx_shp_companyaddress2 varchar(35),
	 dx_shp_companycity varchar(20),
	 dx_shp_companystate varchar(2),
	 dx_shp_companyzip varchar(9),
	 dx_cns_companyname varchar(35),
	 dx_cns_companyaddress1 varchar(35),
	 dx_cns_companyaddress2 varchar(35),
	 dx_cns_companycity varchar(20),
	 dx_cns_companystate varchar(2),
	 dx_cns_companyzip varchar(9),
	 dx_bto_companyname varchar(35),
	 dx_bto_companyaddress1 varchar(35),
	 dx_bto_companyaddress2 varchar(35),
	 dx_bto_companycity varchar(20),
	 dx_bto_companystate varchar(2),
	 dx_bto_companyzip varchar(9),
	 dx_hdr_referencenumbers varchar(1000) default '',
	 dx_hdr_remarks varchar(1750) default '',
	 dx_stopnumber int,
	 dx_stp_event varchar(2),
	 dx_stp_scheduledate varchar(12),
	 dx_stp_earlydate varchar(12),
	 dx_stp_latedate varchar(12),
	 dx_stp_billoflading varchar(20),
	 dx_stp_companyname varchar(35),
	 dx_stp_companyaddress1 varchar(35),
	 dx_stp_companyaddress2 varchar(35),
	 dx_stp_companycity varchar(20),
	 dx_stp_companystate varchar(2),
	 dx_stp_companyzip varchar(9),
	 dx_stp_referencenumbers varchar(1000) default '',
	 dx_stp_remarks varchar(1000) default '',
	 dx_freightnumber int,
	 dx_fgt_quantityunit varchar(6),
	 dx_fgt_quantity varchar(10),
	 dx_fgt_weightunit varchar(6),
	 dx_fgt_weight varchar(10),
	 dx_fgt_volumeunit varchar(6),
	 dx_fgt_volume varchar(10),
	 dx_fgt_rateunit varchar(6),
	 dx_fgt_rate varchar(10),
	 dx_fgt_chargecurrency varchar(1),
	 dx_fgt_charge varchar(10),
	 dx_fgt_commodity varchar(50),
	 dx_fgt_referencenumbers varchar(1000) default '',
	 dx_fgt_remarks varchar(1000) default '')

select @ordhdr = ord_hdrnumber from orderheader where ord_number = @ord_number

select @sourcedate = max(dx_sourcedate) from dx_archive where dx_orderhdrnumber = @ordhdr and dx_importid = 'dx_204'

insert @archive 
select dx_seq, dx_accepted, dx_orderhdrnumber, dx_stopnumber, dx_freightnumber, 
	 dx_field001, dx_field002, dx_field003, dx_field004, dx_field005,
	 dx_field006, dx_field007, dx_field008, dx_field009, dx_field010,
	 dx_field011, dx_field012, dx_field013, dx_field014, dx_field015,
	 dx_field016
  from dx_archive
 where dx_importid = 'dx_204' and dx_orderhdrnumber = @ordhdr and dx_sourcedate = @sourcedate

declare @seq int, @rec varchar(100), @stpnum int, @fgtnum int, @stpseq int, @fgtseq int
select @seq = 0, @stpseq = 0, @fgtseq = 0
while 1=1
begin
	select @seq = min(dx_seq) from @archive where dx_seq > @seq
	if @seq is null break
	select @rec = dx_field001, @stpnum = isnull(dx_stopnumber,0), @fgtnum = isnull(dx_freightnumber,0) from @archive where dx_seq = @seq
	if @rec = '03' select @stpseq = @stpseq + 1, @fgtseq = 0
	if @rec = '04' select @fgtseq = @fgtseq + 1
	if @stpseq > 0
	begin
		if @stpnum = 0 update @archive set dx_stopnumber = @stpseq where dx_seq = @seq
	end
	if @fgtseq > 0 and @rec not in ('06', '07')
	begin
		if @fgtnum = 0 update @archive set dx_freightnumber = @fgtseq where dx_seq = @seq
	end
end

insert @ediorder (dx_orderhdrnumber, dx_sourcedate, dx_hdr_accepted, dx_hdr_isagsid, dx_hdr_purpose, dx_hdr_ordernumber, dx_hdr_bookdate,
	 dx_hdr_startdate, dx_hdr_enddate, dx_hdr_paymentmethod, dx_hdr_totalchargecurrency, dx_hdr_totalcharge, dx_hdr_totalweight,
	 dx_hdr_totalmiles, dx_hdr_totalpieces, dx_hdr_edicontrolnumber, dx_hdr_shipmentnumber, dx_shp_companyname, dx_shp_companyaddress1,
	 dx_shp_companyaddress2, dx_shp_companycity, dx_shp_companystate, dx_shp_companyzip, dx_cns_companyname, dx_cns_companyaddress1,
	 dx_cns_companyaddress2, dx_cns_companycity, dx_cns_companystate, dx_cns_companyzip, dx_bto_companyname, dx_bto_companyaddress1,
	 dx_bto_companyaddress2, dx_bto_companycity, dx_bto_companystate, dx_bto_companyzip, dx_stopnumber, dx_stp_event,
	 dx_stp_scheduledate, dx_stp_earlydate, dx_stp_latedate, dx_stp_billoflading, dx_stp_companyname, dx_stp_companyaddress1,
	 dx_stp_companyaddress2, dx_stp_companycity, dx_stp_companystate, dx_stp_companyzip, dx_freightnumber, dx_fgt_quantityunit,
	 dx_fgt_quantity, dx_fgt_weightunit, dx_fgt_weight, dx_fgt_volumeunit, dx_fgt_volume, dx_fgt_rateunit,
	 dx_fgt_rate, dx_fgt_chargecurrency, dx_fgt_charge, dx_fgt_commodity)
select hdr.dx_orderhdrnumber, @sourcedate, hdr.dx_accepted, hdr.dx_field003, hdr.dx_field004, hdr.dx_field005, hdr.dx_field006, 
	hdr.dx_field007, hdr.dx_field008, hdr.dx_field009, hdr.dx_field010, hdr.dx_field011, hdr.dx_field012, 
	hdr.dx_field013, hdr.dx_field014, hdr.dx_field015, hdr.dx_field016, shp.dx_field004, shp.dx_field005, 
	shp.dx_field006, shp.dx_field007, shp.dx_field008, shp.dx_field009, cns.dx_field004, cns.dx_field005, 
	cns.dx_field006, cns.dx_field007, cns.dx_field008, cns.dx_field009, bto.dx_field004, bto.dx_field005, 
	bto.dx_field006, bto.dx_field007, bto.dx_field008, bto.dx_field009, stp.dx_stopnumber, stp.dx_field003, 
	stp.dx_field004, stp.dx_field005, stp.dx_field006, stp.dx_field007, cmp.dx_field004, cmp.dx_field005, 
	cmp.dx_field006, cmp.dx_field007, cmp.dx_field008, cmp.dx_field009, fgt.dx_freightnumber, fgt.dx_field003, 
	fgt.dx_field004, fgt.dx_field005, fgt.dx_field006, fgt.dx_field007, fgt.dx_field008, fgt.dx_field009, 
	fgt.dx_field010, fgt.dx_field011, fgt.dx_field012, fgt.dx_field013
  from @archive hdr
  left join @archive shp
    on hdr.dx_orderhdrnumber = shp.dx_orderhdrnumber
   and hdr.dx_field001 = '02' and shp.dx_field001 = '06' and shp.dx_field003 = 'SH'
  left join @archive cns
    on hdr.dx_orderhdrnumber = cns.dx_orderhdrnumber
   and hdr.dx_field001 = '02' and cns.dx_field001 = '06' and cns.dx_field003 = 'CO'
  left join @archive bto
    on hdr.dx_orderhdrnumber = bto.dx_orderhdrnumber
   and hdr.dx_field001 = '02' and bto.dx_field001 = '06' and bto.dx_field003 = 'BT'
  left join @archive stp
    on hdr.dx_orderhdrnumber = stp.dx_orderhdrnumber
   and hdr.dx_field001 = '02' and stp.dx_field001 = '03'
  left join @archive cmp
    on stp.dx_stopnumber = cmp.dx_stopnumber
   and stp.dx_field001 = '03' and cmp.dx_field001 = '06' and cmp.dx_field003 = 'ST'
  left join @archive fgt
    on stp.dx_stopnumber = fgt.dx_stopnumber
   and stp.dx_field001 = '03' and fgt.dx_field001 = '04'
 where hdr.dx_field001 = '02'
 order by stp.dx_seq, fgt.dx_seq

declare @type varchar(3), @comment varchar(254), @ident int

select @seq = 0
while 1=1
begin
	select @seq = min(dx_seq) from @archive
	 where dx_field001 = '05' and left(dx_field003, 1) != 'X' and dx_seq > @seq
	if @seq is null break

	select @stpnum = dx_stopnumber, @fgtnum = dx_freightnumber, @type = dx_field003, @comment = case dx_field003 when '_RM' then rtrim(dx_field004) else rtrim(dx_field003) + ': ' + rtrim(dx_field004) end + char(13) + char(10)
	  from @archive
	 where dx_seq = @seq

	if @stpnum > 0 and @fgtnum > 0
		update @ediorder
		   set dx_fgt_referencenumbers = dx_fgt_referencenumbers + case @type when '_RM' then '' else @comment end
		     , dx_fgt_remarks = dx_fgt_remarks + case @type when '_RM' then @comment else '' end
		 where dx_stopnumber = @stpnum and dx_freightnumber = @fgtnum
	else
	begin
		if @stpnum > 0
		begin
			select @ident = 0
			select @ident = min(ident) from @ediorder where dx_stopnumber = @stpnum
			update @ediorder
			   set dx_stp_referencenumbers = dx_stp_referencenumbers + case @type when '_RM' then '' else @comment end
			     , dx_stp_remarks = dx_stp_remarks + case @type when '_RM' then @comment else '' end
			 where ident = @ident
		end
		else
			update @ediorder
			   set dx_hdr_referencenumbers = dx_hdr_referencenumbers + case @type when '_RM' then '' else @comment end
			     , dx_hdr_remarks = dx_hdr_remarks + case @type when '_RM' then @comment else '' end
	end
end

select *, 
	substring(dx_hdr_referencenumbers, 1, 250) as 'HdrRefs1',
	substring(dx_hdr_referencenumbers, 251, 250) as 'HdrRefs2',
	substring(dx_hdr_referencenumbers, 501, 250) as 'HdrRefs3',
	substring(dx_hdr_referencenumbers, 751, 250) as 'HdrRefs4',
	substring(dx_hdr_remarks, 1, 250) as 'HdrRemarks1', 
	substring(dx_hdr_remarks, 251, 250) as 'HdrRemarks2',
	substring(dx_hdr_remarks, 501, 250) as 'HdrRemarks3',
	substring(dx_hdr_remarks, 751, 250) as 'HdrRemarks4',
	substring(dx_hdr_remarks, 1001, 250) as 'HdrRemarks5',
	substring(dx_hdr_remarks, 1251, 250) as 'HdrRemarks6',
	substring(dx_hdr_remarks, 1501, 250) as 'HdrRemarks7',
	substring(dx_stp_referencenumbers, 1, 250) as 'StpRefs1',
	substring(dx_stp_referencenumbers, 251, 250) as 'StpRefs2',
	substring(dx_stp_referencenumbers, 501, 250) as 'StpRefs3',
	substring(dx_stp_referencenumbers, 751, 250) as 'StpRefs4',
	substring(dx_stp_remarks, 1, 250) as 'StpRemarks1',
	substring(dx_stp_remarks, 251, 250) as 'StpRemarks2',
	substring(dx_stp_remarks, 501, 250) as 'StpRemarks3',
	substring(dx_stp_remarks, 751, 250) as 'StpRemarks4',
	substring(dx_fgt_referencenumbers, 1, 250) as 'FgtRef1',
	substring(dx_fgt_referencenumbers, 251, 250) as 'FgtRef2',
	substring(dx_fgt_referencenumbers, 501, 250) as 'FgtRef3',
	substring(dx_fgt_referencenumbers, 751, 250) as 'FgtRef4',
	substring(dx_fgt_remarks, 1, 250) as 'FgtRemarks1',
	substring(dx_fgt_remarks, 251, 250) as 'FgtRemarks2',
	substring(dx_fgt_remarks, 501, 250) as 'FgtRemarks3',
	substring(dx_fgt_remarks, 751, 250) as 'FgtRemarks4'
	 from @ediorder order by ident

GO
GRANT EXECUTE ON  [dbo].[dx_report_EDIOrder] TO [public]
GO
