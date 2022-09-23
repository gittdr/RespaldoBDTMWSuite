CREATE TABLE [dbo].[manpowerhomelog]
(
[mpp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[mhl_start] [datetime] NOT NULL,
[mhl_end] [datetime] NOT NULL,
[mhl_tractor] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create trigger [dbo].[itut_manpowerhomelog] on [dbo].[manpowerhomelog]
for INSERT, UPDATE
as
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
declare @enddate datetime,
        @curr_last_home datetime,
        @mpp_id varchar (8)

select @enddate = mhl_end,
       @mpp_id = mpp_id
  from inserted
--make sure the date is not over a month in the future to prevent a date getting too far out that will fail the next check
if isnull(@mpp_id,'UNKNOWN') <> 'UNKNOWN' and rtrim(ltrim(@mpp_id)) <> ''
  begin
	select @curr_last_home = isnull(mpp_last_home,'01/01/50 00:00:00.000')
	  from manpowerprofile
	 where mpp_id = @mpp_id
	--only update if it's newer than the current last home for performance
	if @enddate < dateadd(mm,1,getdate()) and @enddate > @curr_last_home
		update manpowerprofile
		   set mpp_last_home = @enddate
		 where mpp_id = @mpp_id
  end
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_mpp_start] ON [dbo].[manpowerhomelog] ([mpp_id], [mhl_start]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[manpowerhomelog] TO [public]
GO
GRANT INSERT ON  [dbo].[manpowerhomelog] TO [public]
GO
GRANT REFERENCES ON  [dbo].[manpowerhomelog] TO [public]
GO
GRANT SELECT ON  [dbo].[manpowerhomelog] TO [public]
GO
GRANT UPDATE ON  [dbo].[manpowerhomelog] TO [public]
GO
