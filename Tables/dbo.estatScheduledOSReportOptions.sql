CREATE TABLE [dbo].[estatScheduledOSReportOptions]
(
[rpt_sched_id] [int] NOT NULL,
[UserName] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Clientid] [varchar] (240) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Cancelled] [bit] NOT NULL CONSTRAINT [DF__estatSche__Cance__17D8C453] DEFAULT ((0)),
[NewOrders] [bit] NOT NULL CONSTRAINT [DF__estatSche__NewOr__18CCE88C] DEFAULT ((0)),
[Dispatched] [bit] NOT NULL CONSTRAINT [DF__estatSche__Dispa__19C10CC5] DEFAULT ((0)),
[Inprogress] [bit] NOT NULL CONSTRAINT [DF__estatSche__Inpro__1AB530FE] DEFAULT ((0)),
[Completed] [bit] NOT NULL CONSTRAINT [DF__estatSche__Compl__1BA95537] DEFAULT ((0)),
[Invoiced] [bit] NOT NULL CONSTRAINT [DF__estatSche__Invoi__1C9D7970] DEFAULT ((0)),
[Transferred] [bit] NOT NULL CONSTRAINT [DF__estatSche__Trans__1D919DA9] DEFAULT ((0)),
[DonotInvoice] [bit] NOT NULL CONSTRAINT [DF__estatSche__Donot__1E85C1E2] DEFAULT ((0)),
[Reftype] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Shipper] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Consignee] [varchar] (36) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TRReq] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__estatSche__TRReq__1F79E61B] DEFAULT (''),
[showbillto] [bit] NOT NULL CONSTRAINT [DF__estatSche__showb__206E0A54] DEFAULT ((0)),
[showshipper] [bit] NOT NULL CONSTRAINT [DF__estatSche__shows__21622E8D] DEFAULT ((0)),
[showconsignee] [bit] NOT NULL CONSTRAINT [DF__estatSche__showc__225652C6] DEFAULT ((0)),
[showstopordmiles] [bit] NOT NULL CONSTRAINT [DF__estatSche__shows__234A76FF] DEFAULT ((0)),
[showtriploadmiles] [bit] NOT NULL CONSTRAINT [DF__estatSche__showt__243E9B38] DEFAULT ((0)),
[showtripunloadmiles] [bit] NOT NULL CONSTRAINT [DF__estatSche__showt__2532BF71] DEFAULT ((0)),
[showinvoicestatus] [bit] NOT NULL CONSTRAINT [DF__estatSche__showi__2626E3AA] DEFAULT ((0)),
[showmissingpaperwork] [bit] NOT NULL CONSTRAINT [DF__estatSche__showm__271B07E3] DEFAULT ((0)),
[showcarrier] [bit] NOT NULL CONSTRAINT [DF__estatSche__showc__280F2C1C] DEFAULT ((0)),
[showord_hdrnumber] [bit] NOT NULL CONSTRAINT [DF__estatSche__showo__29035055] DEFAULT ((0)),
[excel] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__estatSche__excel__29F7748E] DEFAULT ('N')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[estatScheduledOSReportOptions] ADD CONSTRAINT [PK_estatScheduledOSReportOptions] PRIMARY KEY NONCLUSTERED ([rpt_sched_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[estatScheduledOSReportOptions] TO [public]
GO
GRANT INSERT ON  [dbo].[estatScheduledOSReportOptions] TO [public]
GO
GRANT SELECT ON  [dbo].[estatScheduledOSReportOptions] TO [public]
GO
GRANT UPDATE ON  [dbo].[estatScheduledOSReportOptions] TO [public]
GO
