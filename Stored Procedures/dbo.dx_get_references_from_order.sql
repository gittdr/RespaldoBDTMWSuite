SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE  proc [dbo].[dx_get_references_from_order]
	@ord_number varchar(12)

as

declare @movnum int, @ordhdrnum int, @stpnum int, @stpseq int, @dxseq int, 
	@stptype varchar(6), @stpid varchar(8), @shipper varchar(8), @showshipper varchar(8),@stpcmdid varchar(8),@fgtnum int
	

declare @archive table
	(dx_importid varchar(8) not null default ('dx_204'),
	 dx_sourcename varchar(255) not null default (''),
	 dx_sourcedate datetime not null default (getdate()),
	 dx_seq int not null,
	 dx_updated char(1) null,
	 dx_accepted bit null,
	 dx_manifestnumber varchar(30) null,
	 dx_manifeststop int null,
	 dx_field001 varchar(200) not null default (''),
	 dx_field002 varchar(200) not null default (''),
	 dx_field003 varchar(200) not null default (''),
	 dx_field004 varchar(200) not null default (''),
	 dx_field005 varchar(200) not null default (''),
	 dx_field006 varchar(200) not null default (''),
	 dx_field007 varchar(200) not null default (''),
	 dx_field008 varchar(200) not null default (''),
	 dx_field009 varchar(200) not null default (''),
	 dx_field010 varchar(200) not null default (''),
	 dx_field011 varchar(200) not null default (''),
	 dx_field012 varchar(200) not null default (''),
	 dx_field013 varchar(200) not null default (''),
	 dx_field014 varchar(200) not null default (''),
	 dx_field015 varchar(200) not null default (''),
	 dx_field016 varchar(200) not null default (''),
	 dx_field017 varchar(200) not null default (''),
	 dx_field018 varchar(200) not null default (''),
	 dx_field019 varchar(200) not null default (''),
	 dx_field020 varchar(200) not null default (''),
	 dx_field021 varchar(200) not null default (''),
	 dx_field022 varchar(200) not null default (''),
	 dx_field023 varchar(200) not null default (''),
	 dx_field024 varchar(200) not null default (''),
	 dx_field025 varchar(200) not null default (''),
	 dx_field026 varchar(200) not null default (''),
	 dx_field027 varchar(200) not null default (''),
	 dx_field028 varchar(200) not null default (''),
	 dx_field029 varchar(200) not null default (''),
	 dx_field030 varchar(200) not null default (''),
	 dx_orderhdrnumber int null,
	 dx_movenumber int null,
	 dx_stopnumber int null,
	 dx_freightnumber int null,
	 dx_ordernumber varchar(30) null,
	 dx_docnumber varchar(9) null,
	 dx_ident bigint IDENTITY,
	 dx_doctype varchar(8) null,
	 [sort_level] int null)

select @movnum = mov_number, @ordhdrnum = ord_hdrnumber from orderheader where ord_number = @ord_number

if isnull(@movnum, 0) > 0
begin	
	select @shipper = ord_shipper, @showshipper = ord_showshipper 
	  from orderheader where ord_hdrnumber = @ordhdrnum

	insert @archive (dx_seq, dx_field001)
	values (1, '02')

	select @dxseq = 2, @stpnum = 0, @stpseq = 0
	while 1=1
	begin
		if @stpseq = 0 
		begin
			if @shipper <> @showshipper and @showshipper <> 'UNKNOWN'
				select @stpseq = min(stp_mfh_sequence) from stops
				 where ord_hdrnumber = @ordhdrnum and cmp_id = @showshipper and (stp_type = 'PUP' or stp_event IN ('BMT','IBMT'))
			if isnull(@stpseq, 0) = 0
				select @stpseq = min(stp_mfh_sequence) from stops
				 where ord_hdrnumber = @ordhdrnum and (stp_type = 'PUP' or stp_event IN ('BMT','IBMT'))
		end
		else
			select @stpseq = min(stp_mfh_sequence) from stops 
			 where mov_number = @movnum and stp_mfh_sequence > @stpseq and (stp_type IN ('PUP','DRP') or stp_event in ('NBCST','BCST','IBMT','IEMT','BMT','EMT'))
		if isnull(@stpseq, 0) = 0 break
		select @stpnum = stp_number, @stpid = cmp_id, @stpcmdid = cmd_code,	--added cmd_code
			   @stptype = case when rTrim(isnull(edicode,'')) > '' then edicode when stp_event in ('IBMT','IEMT','BMT','EMT','NBCST') then stp_event else stp_type end 
		  from stops 
		  join eventcodetable on stp_event = abbr
		  where mov_number = @movnum and stp_mfh_sequence = @stpseq
		insert @archive (dx_seq, dx_field001, dx_field003, dx_stopnumber)
		values (@dxseq, '03', left(@stptype, 2), @stpnum)
		select @dxseq = @dxseq + 1
		
		--insert freight record here
		select @fgtnum = min(fgt_number) from freightdetail where stp_number  = @stpnum  and cmd_code = @stpcmdid 
		
		if isnull(@fgtnum,0) = 0
			select @fgtnum = min(fgt_number) from freightdetail where stp_number  = @stpnum  and cmd_code = @stpcmdid

		if @stptype in('PUP','DRP')
		begin
			if(select count(1) from commodity_xref inner join commodity on commodity_xref.cmd_id = commodity.cmd_code where commodity_xref.cmd_id = @stpcmdid)>0
				insert @archive(dx_seq,dx_field001,dx_field002,dx_field013,dx_field014,dx_stopnumber,dx_freightnumber)
				 select top 1@dxseq,'04','28',ISNULL(commodity_xref.cmd_name,'UNKNOWN'),isnull(commodity_xref.cmd_id,'UNKNOWN'),@stpnum,@fgtnum
				  from commodity_xref
					inner join commodity
						on commodity_xref.cmd_id = commodity.cmd_code
				  where commodity_xref.cmd_id = @stpcmdid
			else
				insert @archive(dx_seq,dx_field001,dx_field002,dx_field014,dx_stopnumber,dx_freightnumber)
				  values(@dxseq,'04','28',@stpcmdid,@stpnum,@fgtnum)

			select 	  @dxseq = @dxseq + 1
		end	
		
		
		--increment the dx_seq here   select @dxseq = @dxseq + 1
		if (select count(1) from company_xref inner join company on company_xref.cmp_id = company.cmp_id where company_xref.cmp_id = @stpid) > 0
			insert @archive (dx_seq, dx_field001, dx_field003, dx_field004, dx_field005, dx_field006, dx_field007, dx_field008, dx_field009, dx_stopnumber)
			select top 1 @dxseq, '06', 'ST', ISNULL(company_xref.cmp_name,'UNKNOWN'), ISNULL(address1,''), ISNULL(address2,''), ISNULL(city,''), ISNULL(state,''), ISNULL(zip,''), @stpnum
			  from company_xref
			 inner join company
			    on company_xref.cmp_id = company.cmp_id
			 where company_xref.cmp_id = @stpid
		else
			insert @archive (dx_seq, dx_field001, dx_field003, dx_field004, dx_field005, dx_field006, dx_field007, dx_field008, dx_field009, dx_stopnumber)
			values (@dxseq, '06', 'ST', @stpid, '', '', '', '', '', @stpnum)
		select @dxseq = @dxseq + 1
	end

	update @archive
	   set dx_orderhdrnumber = @ordhdrnum, dx_movenumber = @movnum
end

	declare @dx_ident int, @dx_seq int,@sort_level int
	declare @dx_field001 varchar(100), @dx_field003 varchar(100), @last_field001 varchar(100)
	set @sort_level = 0
	set @dx_ident = 0
	set @dx_seq = 0
	set @last_field001 = ''

		WHILE 1=1
	BEGIN
		select @dx_ident= min(dx_ident)
		from @archive
		where dx_ident > @dx_ident and dx_field001 in ('02', '05')
		if @dx_ident is null break
		select @dx_field001 = dx_field001, @dx_field003 = dx_field003
		from @archive
		where dx_ident = @dx_ident
		if @dx_field001 = '02'
			begin
			set @sort_level = @sort_level + 1
			update @archive
				set sort_level = @sort_level
				where dx_ident = @dx_ident
			end
		else
		if @dx_field001 = '05' and @dx_field003 = '_RM'
			begin
			set @sort_level = @sort_level + 1
			update @archive
				set sort_level = @sort_level
				where dx_ident = @dx_ident
			END

		set @last_field001 = @dx_field001 
	END
	set @dx_ident = 0
	set @sort_level = @sort_level + 1

	WHILE 1=1
	BEGIN
		select @dx_ident= min(dx_ident)
		from @archive
		where dx_ident > @dx_ident and sort_level is null
		if @dx_ident is null break
		select @dx_field001 = dx_field001
		from @archive
		where dx_ident = @dx_ident
		if @dx_field001 <> @last_field001 or @dx_field001 = '04'
			set @sort_level = @sort_level + 1
			
		update @archive
			set sort_level = @sort_level
			where dx_ident = @dx_ident
		set @last_field001 = @dx_field001 
		--print '@sort_level='+convert(varchar, @sort_level) 
		--print '@last_field001='+@last_field001 
	END

	set @dx_ident = 0
	set @dx_seq = 0
	WHILE 1=1
	BEGIN
		set @dx_ident = null
		select top 1 @dx_ident = dx_ident, @dx_field001 = dx_field001
		from @archive
		where dx_seq is null
		order by sort_level, dx_field003, dx_field004
		if @dx_ident is null break
		set @dx_seq = @dx_seq + 1
		update @archive
			set dx_seq = @dx_seq
			where dx_ident = @dx_ident
		if @dx_field001 = '02'
			update @archive
			set dx_field011 = REPLICATE('0',12-LEN(convert(int,dx_field011)))+convert(varchar(12), convert(int,dx_field011)),
			    dx_field012 = REPLICATE('0',12-LEN(convert(int,dx_field012)))+convert(varchar(12), convert(int,dx_field012)),
				dx_field013 = REPLICATE('0',12-LEN(convert(int,dx_field013)))+convert(varchar(12), convert(int,dx_field013)),
				dx_field014 = REPLICATE('0',12-LEN(convert(int,dx_field014)))+convert(varchar(12), convert(int,dx_field014))
			where dx_ident = @dx_ident
		if @dx_field001 = '04'
			update @archive
			set dx_field004 = REPLICATE('0',10-LEN(convert(varchar(10), convert(int,dx_field004))))+convert(varchar(10), convert(int,dx_field004)),
			    dx_field006 = REPLICATE('0',10-LEN(convert(varchar(10), convert(int,dx_field006))))+convert(varchar(10), convert(int,dx_field006)),
			    dx_field008 = REPLICATE('0',10-LEN(convert(varchar(10), convert(int,dx_field008))))+convert(varchar(10), convert(int,dx_field008)),
				dx_field010 = REPLICATE('0',10-LEN(convert(varchar(10), convert(int,dx_field010))))+convert(varchar(10), convert(int,dx_field010)),
				dx_field012 = REPLICATE('0',10-LEN(convert(varchar(10), convert(int,dx_field012))))+convert(varchar(10), convert(int,dx_field012)),
				dx_field015 = REPLICATE('0',8-LEN(convert(varchar(8), convert(int,dx_field015))))+convert(varchar(8), convert(int,dx_field015)),
				dx_field017 = REPLICATE('0',8-LEN(convert(varchar(8), convert(int,dx_field017))))+convert(varchar(8), convert(int,dx_field017)),
				dx_field019 = REPLICATE('0',8-LEN(convert(varchar(8), convert(int,dx_field019))))+convert(varchar(8), convert(int,dx_field019)),
				dx_field022 = REPLICATE('0',10-LEN(convert(varchar(10), convert(int,dx_field022))))+convert(varchar(10), convert(int,dx_field022)),
				dx_field024 = REPLICATE('0',10-LEN(convert(varchar(10), convert(int,dx_field024))))+convert(varchar(10), convert(int,dx_field024))
			where dx_ident = @dx_ident

		--print '@dx_seq='+convert(varchar, @dx_seq) 
		--print '@dx_ident='+convert(varchar, @dx_ident)
	END



select * from @archive order by dx_ident


GO
GRANT EXECUTE ON  [dbo].[dx_get_references_from_order] TO [public]
GO
