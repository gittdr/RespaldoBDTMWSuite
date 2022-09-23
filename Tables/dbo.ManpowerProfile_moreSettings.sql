CREATE TABLE [dbo].[ManpowerProfile_moreSettings]
(
[Mpp_ms_ID] [int] NOT NULL IDENTITY(1, 1),
[resource_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__ManpowerP__resou__2242D6AC] DEFAULT ('DRV'),
[resource_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AutoCloseStatus] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__ManpowerP__AutoC__2336FAE5] DEFAULT ('DIS'),
[lastupdateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NULL CONSTRAINT [DF__ManpowerP__lastu__242B1F1E] DEFAULT (getdate()),
[TimeLogSource] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OvertimeExempt] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ManpowerProfile_moreSettings] ADD CONSTRAINT [PK_Mpp_ms_ID] PRIMARY KEY CLUSTERED ([Mpp_ms_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ManpowerProfile_moreSettings] ADD CONSTRAINT [fk_Mpp_ms_ResourceID] FOREIGN KEY ([resource_id]) REFERENCES [dbo].[manpowerprofile] ([mpp_id])
GO
GRANT DELETE ON  [dbo].[ManpowerProfile_moreSettings] TO [public]
GO
GRANT INSERT ON  [dbo].[ManpowerProfile_moreSettings] TO [public]
GO
GRANT REFERENCES ON  [dbo].[ManpowerProfile_moreSettings] TO [public]
GO
GRANT SELECT ON  [dbo].[ManpowerProfile_moreSettings] TO [public]
GO
GRANT UPDATE ON  [dbo].[ManpowerProfile_moreSettings] TO [public]
GO
