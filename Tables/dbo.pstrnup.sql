CREATE TABLE [dbo].[pstrnup]
(
[ordid] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ordtyp] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[loadnum] [int] NOT NULL,
[movnum] [int] NULL,
[pickdte] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[picktme] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dropdte] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[droptme] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drvrid] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trailnum] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tractnum] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dotloc] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[shtoid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fromid] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[msgfield] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[loadsts] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[estdte] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[esttme] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[endload] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[release_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[contact] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drvconf] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[temp1] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[evtcod] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trltyp] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[whsemsg] [int] NULL,
[carrier] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userid] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pickup_event] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driveid2] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[appinit] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[splitevt] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tripseq] [int] NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[pstrnup] TO [public]
GO
GRANT INSERT ON  [dbo].[pstrnup] TO [public]
GO
GRANT REFERENCES ON  [dbo].[pstrnup] TO [public]
GO
GRANT SELECT ON  [dbo].[pstrnup] TO [public]
GO
GRANT UPDATE ON  [dbo].[pstrnup] TO [public]
GO
