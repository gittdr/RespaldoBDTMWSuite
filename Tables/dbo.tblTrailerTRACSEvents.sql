CREATE TABLE [dbo].[tblTrailerTRACSEvents]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[Event] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CheckCallAbbr] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SendTextMessage] [int] NULL,
[SendParameter] [int] NULL,
[HasParameters] [int] NULL,
[StandardEvent] [int] NULL,
[CodeType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CheckCallAbbrState] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblTrailerTRACSEvents] ADD CONSTRAINT [PK_tblTrailerTRACSEvents] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblTrailerTRACSEvents] TO [public]
GO
GRANT INSERT ON  [dbo].[tblTrailerTRACSEvents] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblTrailerTRACSEvents] TO [public]
GO
GRANT SELECT ON  [dbo].[tblTrailerTRACSEvents] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblTrailerTRACSEvents] TO [public]
GO
