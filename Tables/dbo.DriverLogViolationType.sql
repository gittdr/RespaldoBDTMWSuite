CREATE TABLE [dbo].[DriverLogViolationType]
(
[ViolationCode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ViolationDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ImportCode] [int] NULL,
[Points] [decimal] (9, 3) NULL,
[DelayDays] [int] NULL,
[SendMacro] [int] NULL,
[Retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsSystemType] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsUserSelectable] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DriverLogViolationType] ADD CONSTRAINT [PK__DriverLogViolati__7605FC98] PRIMARY KEY CLUSTERED ([ViolationCode]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[DriverLogViolationType] TO [public]
GO
GRANT INSERT ON  [dbo].[DriverLogViolationType] TO [public]
GO
GRANT REFERENCES ON  [dbo].[DriverLogViolationType] TO [public]
GO
GRANT SELECT ON  [dbo].[DriverLogViolationType] TO [public]
GO
GRANT UPDATE ON  [dbo].[DriverLogViolationType] TO [public]
GO
