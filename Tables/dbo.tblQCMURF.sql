CREATE TABLE [dbo].[tblQCMURF]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[AuxSN] [int] NOT NULL,
[MCTSN] [int] NULL,
[RoutePositionWhenMsgNotRouted] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__27D3C73A] DEFAULT (1),
[SendPositionQuery] [int] NULL CONSTRAINT [DF__tblQCMURF__SendP__28C7EB73] DEFAULT (1),
[RouteFwdLowMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__29BC0FAC] DEFAULT (1),
[RouteFwdNormalMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__2AB033E5] DEFAULT (1),
[RouteFwdImportantMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__2BA4581E] DEFAULT (1),
[RouteFwdSleepyMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__2C987C57] DEFAULT (1),
[RouteFwdImportantSleepyMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__2D8CA090] DEFAULT (1),
[RouteFwdEmergencyMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__2E80C4C9] DEFAULT (1),
[RouteRtnNormalMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__2F74E902] DEFAULT (1),
[RouteRtnPriorityMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__30690D3B] DEFAULT (1),
[RouteRtnPanicMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__315D3174] DEFAULT (1),
[SendFwdLowMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__SendF__325155AD] DEFAULT (1),
[SendFwdNormalMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__SendF__334579E6] DEFAULT (1),
[SendFwdImportantMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__SendF__34399E1F] DEFAULT (1),
[SendFwdSleepyMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__SendF__352DC258] DEFAULT (1),
[SendFwdImportantSleepyMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__SendF__3621E691] DEFAULT (1),
[SendFwdEmergencyMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__SendF__37160ACA] DEFAULT (1),
[SendFwdOBCMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__SendF__380A2F03] DEFAULT (1),
[RouteFwdOBCMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__38FE533C] DEFAULT (1),
[RouteRtnOBCMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__39F27775] DEFAULT (1),
[SendFwdSensorTracsMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__SendF__3AE69BAE] DEFAULT (1),
[RouteFwdSensorTracsMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__3BDABFE7] DEFAULT (1),
[RouteRtnSensorTracsMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__3CCEE420] DEFAULT (1),
[SendFwdJTracsMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__SendF__3DC30859] DEFAULT (1),
[RouteFwdJTracsMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__3EB72C92] DEFAULT (1),
[RouteRtnJTracsMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__3FAB50CB] DEFAULT (1),
[SendFwdTrailerTracsMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__SendF__409F7504] DEFAULT (1),
[RouteFwdTrailerTracsMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__4193993D] DEFAULT (1),
[RouteRtnTrailerTracsMsg] [int] NULL CONSTRAINT [DF__tblQCMURF__Route__4287BD76] DEFAULT (1),
[AuxIDFwdString] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tblQCMURF__AuxID__437BE1AF] DEFAULT (''),
[AuxIDRtnString] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__tblQCMURF__AuxID__447005E8] DEFAULT (''),
[MURFStatus] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblQCMURF] TO [public]
GO
GRANT INSERT ON  [dbo].[tblQCMURF] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblQCMURF] TO [public]
GO
GRANT SELECT ON  [dbo].[tblQCMURF] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblQCMURF] TO [public]
GO
