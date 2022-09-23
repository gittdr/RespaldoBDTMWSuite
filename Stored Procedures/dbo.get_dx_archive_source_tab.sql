SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[get_dx_archive_source_tab]
	@start bigint,
	@end bigint
AS

/*******************************************************************************************************************  
  Object Description:
  get_dx_archive_source_tab populates source tab in DX
  Revision History:
  Date         Name             Label/PTS    Description
  -----------  ---------------  ----------  ------------------------------------------------------------------------
  03/17/2017   David Wilks      INT-200239  add dx_archive_header_id to output
********************************************************************************************************************/

declare @dx_archive table (
[dx_ident] [bigint] NOT NULL ,
		[dx_importid] [varchar] (8) NOT NULL ,
		[dx_sourcename] [varchar] (255) NOT NULL ,
		[dx_sourcedate] [datetime] NOT NULL ,
		[dx_seq] [int] NULL ,
		[dx_updated] [char] (1) NULL ,
		[dx_accepted] [bit] NULL ,
		[dx_ordernumber] [varchar] (30) NULL ,
		[dx_orderhdrnumber] [int] NULL ,
		[dx_movenumber] [int] NULL ,
		[dx_stopnumber] [int] NULL ,
		[dx_freightnumber] [int] NULL ,
		[dx_docnumber] [varchar] (9) NULL ,
		[dx_manifestnumber] [varchar] (20) NULL ,
		[dx_manifeststop] [int] NULL ,
		[dx_batchref] [int] NULL ,
		[dx_field001] [varchar] (200) NULL,
		[dx_field002] [varchar] (200) NULL,
		[dx_field003] [varchar] (200) NULL,
		[dx_field004] [varchar] (200) NULL,
		[dx_field005] [varchar] (200) NULL,
		[dx_field006] [varchar] (200) NULL,
		[dx_field007] [varchar] (200) NULL,
		[dx_field008] [varchar] (200) NULL,
		[dx_field009] [varchar] (200) NULL,
		[dx_field010] [varchar] (200) NULL,
		[dx_field011] [varchar] (200) NULL,
		[dx_field012] [varchar] (200) NULL,
		[dx_field013] [varchar] (200) NULL,
		[dx_field014] [varchar] (200) NULL,
		[dx_field015] [varchar] (200) NULL,
		[dx_field016] [varchar] (200) NULL,
		[dx_field017] [varchar] (200) NULL,
		[dx_field018] [varchar] (200) NULL,
		[dx_field019] [varchar] (200) NULL,
		[dx_field020] [varchar] (200) NULL,
		[dx_field021] [varchar] (200) NULL,
		[dx_field022] [varchar] (200) NULL,
		[dx_field023] [varchar] (200) NULL,
		[dx_field024] [varchar] (200) NULL,
		[dx_field025] [varchar] (200) NULL,
		[dx_field026] [varchar] (200) NULL,
		[dx_field027] [varchar] (200) NULL,
		[dx_field028] [varchar] (200) NULL,
		[dx_field029] [varchar] (200) NULL,
		[dx_field030] [varchar] (200) NULL,
		[dx_field031] [varchar] (200) NULL,
		[dx_field032] [varchar] (200) NULL,
		[dx_field033] [varchar] (200) NULL,
		[dx_field034] [varchar] (200) NULL,
		[dx_field035] [varchar] (200) NULL,
		[dx_doctype] [varchar] (8) NULL,
		[dx_billto] [varchar] (8) NULL,
		[dx_sourcedate_reference] [datetime] NULL,
		[dx_processed] [varchar](6) NULL,
		[dx_createdby] [varchar](20) NULL,
		[dx_createdate] [datetime] NULL,
		[dx_updatedby] [varchar](20) NULL,
		[dx_updatedate] [datetime] NULL,
		[dx_trpid] [varchar] (20) Null,
		[dx_archive_header_id] bigint Null,
		[sort_level] int null
	)

insert @dx_archive(dx_ident, dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, dx_orderhdrnumber, 
		dx_movenumber, dx_stopnumber, dx_freightnumber 
		,dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype 
		,dx_field001, dx_field002, dx_field003, dx_field004, dx_field005
		, dx_field006
		, dx_field007 
		,dx_field008, dx_field009, dx_field010, dx_field011, dx_field012, dx_field013, dx_field014, 
		dx_field015, dx_field016, dx_field017, dx_field018, dx_field019, dx_field020, dx_field021, 
		dx_field022, dx_field023, dx_field024, dx_field025, dx_field026, dx_field027, dx_field028, 
		dx_field029, dx_field030, dx_billto, dx_trpid, dx_processed, dx_archive_header_id
		)
	SELECT 
		dx_ident, dx_importid, dx_sourcename, dx_sourcedate, dx_updated, dx_accepted, 
		dx_ordernumber, 
		orderheader.ord_number as 'dx_orderhdrnumber', 
		dx_movenumber, dx_stopnumber, dx_freightnumber, 
		dx_docnumber, dx_manifestnumber, dx_manifeststop, dx_batchref, dx_doctype, 
		dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006, dx_field007, 
		dx_field008, dx_field009, dx_field010, dx_field011, dx_field012, dx_field013, dx_field014, 
		dx_field015, dx_field016, dx_field017, dx_field018, dx_field019, dx_field020, dx_field021, 
		dx_field022, dx_field023, dx_field024, dx_field025, dx_field026, dx_field027, dx_field028, 
		dx_field029, dx_field030, dx_billto, dx_trpid, dx_processed, dx_archive_header_id
	FROM 
		dx_archive WITH (NOLOCK)
	LEFT OUTER JOIN
		orderheader (NOLOCK)
	ON
		dx_archive.dx_orderhdrnumber = orderheader.ord_hdrnumber
	where dx_ident between @start and @end and IsNull(dx_importid,'') = 'dx_204'	

	declare @dx_ident int, @dx_seq int,@sort_level int
	declare @dx_field001 varchar(100), @dx_field003 varchar(100), @last_field001 varchar(100)
	set @sort_level = 0
	set @dx_ident = 0
	set @dx_seq = 0
	set @last_field001 = ''

		WHILE 1=1
	BEGIN
		select @dx_ident= min(dx_ident)
		from @dx_archive
		where dx_ident > @dx_ident and dx_field001 in ('02', '05')
		if @dx_ident is null break
		select @dx_field001 = dx_field001, @dx_field003 = dx_field003
		from @dx_archive
		where dx_ident = @dx_ident
		if @dx_field001 = '02'
			begin
			set @sort_level = @sort_level + 1
			update @dx_archive
				set sort_level = @sort_level
				where dx_ident = @dx_ident
			end
		else
		if @dx_field001 = '05' and @dx_field003 = '_RM'
			begin
			set @sort_level = @sort_level + 1
			update @dx_archive
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
		from @dx_archive
		where dx_ident > @dx_ident and sort_level is null
		if @dx_ident is null break
		select @dx_field001 = dx_field001
		from @dx_archive
		where dx_ident = @dx_ident
		if @dx_field001 <> @last_field001 or @dx_field001 = '04'
			set @sort_level = @sort_level + 1
			
		update @dx_archive
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
		select top 1 @dx_ident = dx_ident, @dx_field001 = dx_field001, @dx_field003 = dx_field003
		from @dx_archive
		where dx_seq is null
		order by sort_level, dx_field003, dx_field004
		if @dx_ident is null break
		set @dx_seq = @dx_seq + 1
		update @dx_archive
			set dx_seq = @dx_seq
			where dx_ident = @dx_ident
		if @dx_field001 = '02'
			update @dx_archive
			set dx_field011 = REPLICATE('0',12-LEN(convert(int,dx_field011)))+convert(varchar(12), convert(int,dx_field011)),
			    dx_field012 = REPLICATE('0',12-LEN(convert(int,dx_field012)))+convert(varchar(12), convert(int,dx_field012)),
				dx_field013 = REPLICATE('0',12-LEN(convert(int,dx_field013)))+convert(varchar(12), convert(int,dx_field013)),
				dx_field014 = REPLICATE('0',12-LEN(convert(int,dx_field014)))+convert(varchar(12), convert(int,dx_field014))
			where dx_ident = @dx_ident
		if @dx_field001 = '04'
			update @dx_archive
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


		if @dx_field001 = '05' and @dx_field003 = 'RES'
			update @dx_archive
			set dx_field004 = SUBSTRING(IsNull(dx_field004,'               '),1,12)
			where dx_ident = @dx_ident


		--print '@dx_seq='+convert(varchar, @dx_seq) 
		--print '@dx_ident='+convert(varchar, @dx_ident)
	END
	select 
		dx_importid, dx_sourcename, dx_sourcedate, dx_seq, dx_updated, dx_accepted, dx_manifestnumber, dx_manifeststop, dx_field001, dx_field002, dx_field003, dx_field004, dx_field005, dx_field006, dx_field007, dx_field008, dx_field009, dx_field010, dx_field011, dx_field012, dx_field013,dx_field014, dx_field015, dx_field016, dx_field017, dx_field018, dx_field019, dx_field020, dx_field021, dx_field022, dx_field023, dx_field024,dx_field025, dx_field026, dx_field027, dx_field028, dx_field029, dx_field030, dx_field031, dx_field032, dx_field033, dx_field034, dx_field035, dx_orderhdrnumber, dx_movenumber, dx_stopnumber,dx_freightnumber, dx_ordernumber, dx_docnumber, dx_ident, dx_doctype, dx_processed, dx_billto , dx_archive_header_id
	from @dx_archive order by dx_seq
GO
GRANT EXECUTE ON  [dbo].[get_dx_archive_source_tab] TO [public]
GO
