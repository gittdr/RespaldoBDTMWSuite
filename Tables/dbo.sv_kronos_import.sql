CREATE TABLE [dbo].[sv_kronos_import]
(
[kronos_ident] [int] NOT NULL IDENTITY(1, 1),
[drv_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drv_altid] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[work_date] [datetime] NOT NULL,
[in_time] [datetime] NOT NULL,
[out_time] [datetime] NOT NULL,
[pyd_number] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[dt_sv_kronos_import] ON [dbo].[sv_kronos_import]
FOR DELETE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
  begin
    declare @minid int, @maxid int, @counter int, @pydnum int
	select @minid = min(kronos_ident),
	       @maxid = max(kronos_ident)
	  from deleted
	set @counter = @maxid
	while @counter >= @minid
	  begin
	    delete from paydetail
	    from deleted
	    where deleted.pyd_number = paydetail.pyd_number
	      and paydetail.pyd_status = 'PND'
	      and pyh_number = 0
	    select @counter = @counter -1
	  end
  end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_sv_kronos_import] ON [dbo].[sv_kronos_import]
FOR INSERT
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
  begin
    declare @pydnum int, @pyd_sequence int, @pyd_minus int
    declare @drv_id varchar(8), @drv_altid varchar(9), @mpp_payto varchar(12), @pyt_description varchar(30)
    declare @pyt_rateunit varchar(6), @pyt_unit varchar(6), @pyt_glnum varchar(32)
    declare @pyd_quantity float
    declare @workdate datetime, @starttime datetime, @endtime datetime
    declare @pyt_pretax char(1), @acct_type char (1), @paytype varchar(6)
	--PTS 23691 CGK 9/3/2004
	DECLARE @tmwuser varchar (255)
	exec gettmwuser @tmwuser output

    --sync up the drv_id and altid based on what was inserted into the table
	select @drv_id = drv_id, @drv_altid = drv_altid
	  from inserted
	--both are NULL error out
	if @drv_id is null AND @drv_altid is NULL
	  RAISERROR('No Driver was associated with the insert',16,1)
	--drv id is not given but alt was so sync based on alt id
	else if @drv_id is null AND @drv_altid is not NULL
	  begin
	    select @drv_id = mpp_id
              from manpowerprofile
	     where manpowerprofile.mpp_otherid = @drv_altid
	    if @drv_id is null
	      RAISERROR('Alt ID %s is not assigned to any driver profile',16,1,@drv_altid)
	    else
	      update sv_kronos_import
	         set drv_id = @drv_id
           where drv_altid = @drv_altid
	  end
	--drv alt id is not given but id was so sync based on id
	else if @drv_altid is null AND @drv_id is not NULL
	  begin
	    select @drv_altid = mpp_otherid
              from manpowerprofile
	     where manpowerprofile.mpp_id = @drv_id
	    if @drv_id is null
	      RAISERROR('Driver ID %s does not have an alt id assigned in the driver profile',16,1,@drv_id)
	    else
	      update sv_kronos_import
	         set drv_altid = @drv_altid
           where drv_id = @drv_id
	  end
    --calculate the time difference between time in and time out
    select @workdate = work_date, @starttime = in_time, @endtime = out_time
      from inserted

    select @pyd_quantity = isnull(convert(float,datediff(mi,convert(datetime,convert(varchar(2),datepart(mm,@workdate)) + '/' + convert(varchar(2),datepart(dd,@workdate)) + '/' + convert(varchar(4),datepart(yy,@workdate)) + ' ' + convert(varchar(2),datepart(hh,@starttime)) + ':' + convert(varchar(2),datepart(mi,@starttime)) + ':' + convert(varchar(2),datepart(s,@starttime)) + '.'  + convert(varchar(3),datepart(ms,@starttime))),convert(datetime,convert(varchar(2),datepart(mm,@workdate)) + '/' + convert(varchar(2),datepart(dd,@workdate)) + '/' + convert(varchar(4),datepart(yy,@workdate)) + ' ' + convert(varchar(2),datepart(hh,@endtime)) + ':' + convert(varchar(2),datepart(mi,@endtime)) + ':' + convert(varchar(2),datepart(s,@endtime)) + '.'  + convert(varchar(3),datepart(ms,@endtime)))))/convert(float,60),0)
    if @pyd_quantity < 0
	      select @pyd_quantity = @pyd_quantity + 24.0

--get the payto and accounting type
    select @mpp_payto = mpp_payto, @acct_type = mpp_actg_type
      from manpowerprofile
     where mpp_id = @drv_id

--get info from paytype that is set in the generalinfo
    select @paytype = rtrim(ltrim(gi_string1))
      from generalinfo
     where gi_name = 'Kronos Paytype'

--make sure the generalinfo setting is present and the paytype exists
    if @paytype = 'UNK' OR @paytype is null OR (select count(*) from paytype where pyt_itemcode = @paytype) <> 1
      begin
	RAISERROR('Paytype for Kronos import is missing or incorrect in the generalinfo.  Please correct this value.',16,1)
	ROLLBACK
     end
--also make sure that it is hourly basis
    if (select pyt_unit from paytype where pyt_itemcode = @paytype) <> 'HRS'
      begin
	RAISERROR('Paytype for Kronos import in the generalinfo is not based on hours.  Please correct this.',16,1)
	ROLLBACK
     end

    select @pyt_description = pyt_description,
	   @pyt_rateunit = pyt_rateunit,
	   @pyt_unit = pyt_unit,
	   @pyt_pretax = pyt_pretax,
		@pyd_minus = CASE pyt_minus
						 WHEN 'N' THEN 1
						 ELSE 0 END,
	   @pyt_glnum = CASE @acct_type
			WHEN 'A' THEN pyt_pr_glnum  --accounts payable
			WHEN 'P' THEN pyt_ap_glnum  --payroll
			ELSE NULL END		    --anything else including none
      from paytype
     where pyt_itemcode = @paytype

    --get the pyd_sequence
    select @pyd_sequence = isnull(max(pyd_sequence),0)+ 1
      from paydetail
     where asgn_type = 'DRV'
       and asgn_id = @drv_id
       and pyh_number = 0

    --get a paydetail number and then create the paydetail
    EXEC @pydnum = getsystemnumberblock 'PYDNUM',null,1

    update sv_kronos_import
       set pyd_number = @pydnum
      from inserted
     where inserted.kronos_ident = sv_kronos_import.kronos_ident

    insert paydetail (	pyd_number,		--1
			pyh_number,		--2
			asgn_type,		--3
			asgn_id,		--4
			pyd_payto,		--5
			pyt_itemcode,		--6
			pyd_description,	--7
			pyd_rate,		--8
			pyd_quantity,		--9
			pyd_rateunit,		--10
			pyd_pretax,		--11
			pyd_glnum,		--12
			pyh_payperiod,		--13
			pyd_workperiod,		--14
			pyd_status,		--15
			pyd_transdate,		--16
			pyd_minus,			--17
			pyd_sequence,		--18
			pyd_loadstate,		--19
			pyd_releasedby,		--20
			pyd_hourlypaydate)	--21
	values (	
			@pydnum,				--1
			0,					--2
			'DRV',					--3
			@drv_id,				--4
			@mpp_payto,				--5
			@paytype,					--6
			@pyt_description,			--7
			0,					--8
			@pyd_quantity,				--9
			@pyt_rateunit,				--10
			@pyt_pretax,				--11
			@pyt_glnum,				--12
			'12/31/49 0:0:0.0',			--13
			'12/31/49 0:0:0.0',			--14
			'PND',					--15
			'12/31/49 0:0:0.0',			--16
			@pyd_minus,					--17
			@pyd_sequence,				--18
			'NA',					--19
			--suser_sname(),				--20
			@tmwuser,			--20
			@workdate)				--21
  end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[ut_sv_kronos_import] ON [dbo].[sv_kronos_import]
FOR UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
  begin
    declare @minid int, @maxid int, @counter int
    declare @workdate datetime, @starttime datetime, @endtime datetime
    declare @pyd_quantity float
	--exit out if updating the paydetail number  this is done in the insert trigger to 
	--write the paydetail number back to the kronos tables  If this is not checked update trigger
	--is called when you insert
	IF UPDATE(pyd_number)
		return
	--handle multiple updates
	select @minid = min(kronos_ident),
	       @maxid = max(kronos_ident)
	  from inserted
	set @counter = @maxid
	while @counter >= @minid
	  begin
	    select @workdate = work_date, 
		   @starttime = in_time, 
		   @endtime = out_time
	    from inserted
	    where inserted.kronos_ident = @counter

	    select @pyd_quantity = isnull(convert(float,datediff(mi,convert(datetime,convert(varchar(2),datepart(mm,@workdate)) + '/' + convert(varchar(2),datepart(dd,@workdate)) + '/' + convert(varchar(4),datepart(yy,@workdate)) + ' ' + convert(varchar(2),datepart(hh,@starttime)) + ':' + convert(varchar(2),datepart(mi,@starttime)) + ':' + convert(varchar(2),datepart(s,@starttime)) + '.'  + convert(varchar(3),datepart(ms,@starttime))),convert(datetime,convert(varchar(2),datepart(mm,@workdate)) + '/' + convert(varchar(2),datepart(dd,@workdate)) + '/' + convert(varchar(4),datepart(yy,@workdate)) + ' ' + convert(varchar(2),datepart(hh,@endtime)) + ':' + convert(varchar(2),datepart(mi,@endtime)) + ':' + convert(varchar(2),datepart(s,@endtime)) + '.'  + convert(varchar(3),datepart(ms,@endtime)))))/convert(float,60),0)
	    if @pyd_quantity < 0
		select @pyd_quantity = @pyd_quantity + 24.0

	    update paydetail
	    set pyd_quantity = @pyd_quantity,
		pyd_hourlypaydate = @workdate	
	    from inserted
	    where inserted.pyd_number = paydetail.pyd_number
	      and inserted.kronos_ident = @counter
	      and paydetail.pyd_status = 'PND'
	      and paydetail.pyh_number = 0
	    select @counter = @counter -1
	  end
  end
GO
ALTER TABLE [dbo].[sv_kronos_import] ADD CONSTRAINT [PK__sv_kronos_import__387E332E] PRIMARY KEY CLUSTERED ([kronos_ident]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_sv_kronos_import] ON [dbo].[sv_kronos_import] ([drv_id], [work_date], [in_time], [out_time]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[sv_kronos_import] TO [public]
GO
GRANT INSERT ON  [dbo].[sv_kronos_import] TO [public]
GO
GRANT REFERENCES ON  [dbo].[sv_kronos_import] TO [public]
GO
GRANT SELECT ON  [dbo].[sv_kronos_import] TO [public]
GO
GRANT UPDATE ON  [dbo].[sv_kronos_import] TO [public]
GO
