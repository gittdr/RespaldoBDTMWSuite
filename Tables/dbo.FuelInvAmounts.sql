CREATE TABLE [dbo].[FuelInvAmounts]
(
[inv_id] [int] NOT NULL IDENTITY(1, 1),
[cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[inv_date] [datetime] NOT NULL,
[inv_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[inv_sequence] [int] NOT NULL,
[inv_value1] [int] NOT NULL CONSTRAINT [DF__FuelInvAm__inv_v__1E65C651] DEFAULT ((0)),
[inv_value2] [int] NOT NULL CONSTRAINT [DF__FuelInvAm__inv_v__1F59EA8A] DEFAULT ((0)),
[inv_value3] [int] NOT NULL CONSTRAINT [DF__FuelInvAm__inv_v__204E0EC3] DEFAULT ((0)),
[inv_value4] [int] NOT NULL CONSTRAINT [DF__FuelInvAm__inv_v__214232FC] DEFAULT ((0)),
[inv_value5] [int] NOT NULL CONSTRAINT [DF__FuelInvAm__inv_v__22365735] DEFAULT ((0)),
[inv_value6] [int] NOT NULL CONSTRAINT [DF__FuelInvAm__inv_v__232A7B6E] DEFAULT ((0)),
[ord_hdrnumber] [int] NULL,
[inv_comment] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inv_readingdate] [datetime] NULL,
[inv_source1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__FuelInvAm__inv_s__7EB810CE] DEFAULT ('UNK'),
[inv_readingdate1] [datetime] NULL,
[inv_source2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__FuelInvAm__inv_s__0B1DE7B3] DEFAULT ('UNK'),
[inv_source3] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__FuelInvAm__inv_s__0C120BEC] DEFAULT ('UNK'),
[inv_source4] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__FuelInvAm__inv_s__0D063025] DEFAULT ('UNK'),
[inv_source5] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__FuelInvAm__inv_s__0DFA545E] DEFAULT ('UNK'),
[inv_source6] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__FuelInvAm__inv_s__0EEE7897] DEFAULT ('UNK'),
[inv_readingdate2] [datetime] NULL,
[inv_readingdate3] [datetime] NULL,
[inv_readingdate4] [datetime] NULL,
[inv_readingdate5] [datetime] NULL,
[inv_readingdate6] [datetime] NULL,
[inv_forecast1] [int] NULL,
[inv_forecast2] [int] NULL,
[inv_forecast3] [int] NULL,
[inv_forecast4] [int] NULL,
[inv_forecast5] [int] NULL,
[inv_forecast6] [int] NULL,
[inv_excludeday] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[inv_source7] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__FuelInvAm__inv_s__318254A3] DEFAULT ('UNK'),
[inv_source8] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__FuelInvAm__inv_s__327678DC] DEFAULT ('UNK'),
[inv_source9] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__FuelInvAm__inv_s__336A9D15] DEFAULT ('UNK'),
[inv_source10] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__FuelInvAm__inv_s__345EC14E] DEFAULT ('UNK'),
[inv_value7] [int] NOT NULL CONSTRAINT [DF__FuelInvAm__inv_v__3552E587] DEFAULT ((0)),
[inv_value8] [int] NOT NULL CONSTRAINT [DF__FuelInvAm__inv_v__364709C0] DEFAULT ((0)),
[inv_value9] [int] NOT NULL CONSTRAINT [DF__FuelInvAm__inv_v__373B2DF9] DEFAULT ((0)),
[inv_value10] [int] NOT NULL CONSTRAINT [DF__FuelInvAm__inv_v__382F5232] DEFAULT ((0)),
[inv_forecast7] [int] NULL,
[inv_forecast8] [int] NULL,
[inv_forecast9] [int] NULL,
[inv_forecast10] [int] NULL,
[inv_readingdate7] [datetime] NULL,
[inv_readingdate8] [datetime] NULL,
[inv_readingdate9] [datetime] NULL,
[inv_readingdate10] [datetime] NULL,
[inv_readingreviewed1] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_fuelinvamounts_inv_readingreviewed1] DEFAULT ('N'),
[inv_readingreviewed2] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_fuelinvamounts_inv_readingreviewed2] DEFAULT ('N'),
[inv_readingreviewed3] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_fuelinvamounts_inv_readingreviewed3] DEFAULT ('N'),
[inv_readingreviewed4] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_fuelinvamounts_inv_readingreviewed4] DEFAULT ('N'),
[inv_readingreviewed5] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_fuelinvamounts_inv_readingreviewed5] DEFAULT ('N'),
[inv_readingreviewed6] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_fuelinvamounts_inv_readingreviewed6] DEFAULT ('N'),
[inv_readingreviewed7] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_fuelinvamounts_inv_readingreviewed7] DEFAULT ('N'),
[inv_readingreviewed8] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_fuelinvamounts_inv_readingreviewed8] DEFAULT ('N'),
[inv_readingreviewed9] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_fuelinvamounts_inv_readingreviewed9] DEFAULT ('N'),
[inv_readingreviewed10] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_fuelinvamounts_inv_readingreviewed10] DEFAULT ('N')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[uit_fuelinvamounts] on [dbo].[FuelInvAmounts] for insert,update
as

 declare @inv_id int
 select @inv_id = -1
 while exists (select * from inserted where inv_id > @inv_id)
 begin
  select @inv_id = min(inv_id) from inserted where inv_id > @inv_id
  declare @o1 int, @o2 int, @o3 int, @o4 int,@o5 int,@o6 int
  declare @n1 int, @n2 int, @n3 int, @n4 int,@n5 int,@n6 int
  declare @of1 int, @of2 int, @of3 int, @of4 int,@of5 int,@of6 int
  declare @nf1 int, @nf2 int, @nf3 int, @nf4 int,@nf5 int,@nf6 int
  declare @cmp_id varchar(8), @dt as varchar(25)
  select @o1 = -1, @o2 = -1, @o3 = -1, @o4 = -1,@o5 = -1,@o6 = -1
  select @n1 = -1, @n2 = -1, @n3 = -1, @n4 = -1,@n5 = -1,@n6 = -1
  select @of1 = -1, @of2 = -1, @of3 = -1, @of4 = -1,@of5 = -1,@of6 = -1
  select @nf1 = -1, @nf2 = -1, @nf3 = -1, @nf4 = -1,@nf5 = -1,@nf6 = -1
  select @n1 = isnull(inv_value1,-1), @n2 = isnull(inv_value2,-1), @n3 = isnull(inv_value3,-1), 
    @n4 = isnull(inv_value4,-1), @n5 = isnull(inv_value5,-1), @n6 = isnull(inv_value6,-1),
    @nf1 = isnull(inv_forecast1,-1), @nf2 = isnull(inv_forecast2,-1), @nf3 = isnull(inv_forecast3,-1), 
    @nf4 = isnull(inv_forecast4,-1), @nf5 = isnull(inv_forecast5,-1), @nf6 = isnull(inv_forecast6,-1),
    @cmp_id = cmp_id, @dt = convert(varchar(25), inv_date, 1)
    from inserted where inv_id  = @inv_id
  select @o1 = isnull(inv_value1,-1), @o2 = isnull(inv_value2,-1), @o3 = isnull(inv_value3,-1), 
    @o4 = isnull(inv_value4,-1), @o5 = isnull(inv_value5,-1), @o6 = isnull(inv_value6,-1),
    @of1 = isnull(inv_forecast1,-1), @of2 = isnull(inv_forecast2,-1), @of3 = isnull(inv_forecast3,-1), 
    @of4 = isnull(inv_forecast4,-1), @of5 = isnull(inv_forecast5,-1), @of6 = isnull(inv_forecast6,-1)
    from deleted where inv_id  = @inv_id
  
  if @o1 <> @n1 and (@o1 <> -1 and @n1 <> 0) 
   insert CommonAuditLog(Application, IsError, KeyData1, KeyData2, LogMessage, LogDate, UserId)
   select 'InvSrv', 'N', @cmp_id, @dt, 'Reading1 = ' + convert(varchar(15), @n1), getdate(), suser_sname()
  if @o2 <> @n2 and (@o2 <> -1 and @n2 <> 0) 
   insert CommonAuditLog(Application, IsError, KeyData1, KeyData2, LogMessage, LogDate, UserId)
   select 'InvSrv', 'N', @cmp_id, @dt, 'Reading2 = ' + convert(varchar(15), @n2), getdate(), suser_sname()
  if @o3 <> @n3 and (@o3 <> -1 and @n3 <> 0) 
   insert CommonAuditLog(Application, IsError, KeyData1, KeyData2, LogMessage, LogDate, UserId)
   select 'InvSrv', 'N', @cmp_id, @dt, 'Reading3 = ' + convert(varchar(15), @n3), getdate(), suser_sname()
  if @o4 <> @n4 and (@o4 <> -1 and @n4 <> 0) 
   insert CommonAuditLog(Application, IsError, KeyData1, KeyData2, LogMessage, LogDate, UserId)
   select 'InvSrv', 'N', @cmp_id, @dt, 'Reading4 = ' + convert(varchar(15), @n4), getdate(), suser_sname()
  if @o5 <> @n5 and (@o5 <> -1 and @n5 <> 0) 
   insert CommonAuditLog(Application, IsError, KeyData1, KeyData2, LogMessage, LogDate, UserId)
   select 'InvSrv', 'N', @cmp_id, @dt, 'Reading5 = ' + convert(varchar(15), @n5), getdate(), suser_sname()
  if @o6 <> @n6 and (@o6 <> -1 and @n6 <> 0) 
   insert CommonAuditLog(Application, IsError, KeyData1, KeyData2, LogMessage, LogDate, UserId)
   select 'InvSrv', 'N', @cmp_id, @dt, 'Reading6 = ' + convert(varchar(15), @n6), getdate(), suser_sname()
  if @of1 <> @nf1 and @nf1 > 0 
   insert CommonAuditLog(Application, IsError, KeyData1, KeyData2, LogMessage, LogDate, UserId)
   select 'InvSrv', 'N', @cmp_id, @dt, 'Forecast1 = ' + convert(varchar(15), @nf1), getdate(), suser_sname()
  if @of2 <> @nf2 and @nf2 > 0 
   insert CommonAuditLog(Application, IsError, KeyData1, KeyData2, LogMessage, LogDate, UserId)
   select 'InvSrv', 'N', @cmp_id, @dt, 'Forecast2 = ' + convert(varchar(15), @nf2), getdate(), suser_sname()
  if @of3 <> @nf3 and @nf3 > 0 
   insert CommonAuditLog(Application, IsError, KeyData1, KeyData2, LogMessage, LogDate, UserId)
   select 'InvSrv', 'N', @cmp_id, @dt, 'Forecast3 = ' + convert(varchar(15), @nf3), getdate(), suser_sname()
  if @of4 <> @nf4 and @nf4 > 0 
   insert CommonAuditLog(Application, IsError, KeyData1, KeyData2, LogMessage, LogDate, UserId)
   select 'InvSrv', 'N', @cmp_id, @dt, 'Forecast4 = ' + convert(varchar(15), @nf4), getdate(), suser_sname()
  if @of5 <> @nf5 and @nf5 > 0 
   insert CommonAuditLog(Application, IsError, KeyData1, KeyData2, LogMessage, LogDate, UserId)
   select 'InvSrv', 'N', @cmp_id, @dt, 'Forecast5 = ' + convert(varchar(15), @nf5), getdate(), suser_sname()
  if @of6 <> @nf6 and @nf6 > 0 
   insert CommonAuditLog(Application, IsError, KeyData1, KeyData2, LogMessage, LogDate, UserId)
   select 'InvSrv', 'N', @cmp_id, @dt, 'Forecast6 = ' + convert(varchar(15), @nf6), getdate(), suser_sname()
 end
GO
ALTER TABLE [dbo].[FuelInvAmounts] ADD CONSTRAINT [PK__FuelInvAmounts__1D71A218] PRIMARY KEY CLUSTERED ([inv_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FuelInvAmounts_cmp_id_inv_date] ON [dbo].[FuelInvAmounts] ([cmp_id], [inv_date]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_CompanyID_ReadingDate_ID] ON [dbo].[FuelInvAmounts] ([cmp_id], [inv_readingdate], [inv_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dx_CompanyID_Type_Values_ID] ON [dbo].[FuelInvAmounts] ([cmp_id], [inv_value1], [inv_type], [inv_value2], [inv_value3], [inv_value4], [inv_value5], [inv_value6], [inv_value7], [inv_value8], [inv_value9], [inv_value10], [inv_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[FuelInvAmounts] TO [public]
GO
GRANT INSERT ON  [dbo].[FuelInvAmounts] TO [public]
GO
GRANT SELECT ON  [dbo].[FuelInvAmounts] TO [public]
GO
GRANT UPDATE ON  [dbo].[FuelInvAmounts] TO [public]
GO
