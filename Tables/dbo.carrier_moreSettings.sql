CREATE TABLE [dbo].[carrier_moreSettings]
(
[car_ms_ID] [int] NOT NULL IDENTITY(1, 1),
[resource_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__carrier_m__resou__27FBB002] DEFAULT ('CAR'),
[resource_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AutoCloseStatus] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__carrier_m__AutoC__28EFD43B] DEFAULT ('DIS'),
[lastupdateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NULL CONSTRAINT [DF__carrier_m__lastu__29E3F874] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrier_moreSettings] ADD CONSTRAINT [PK_car_ms_ID] PRIMARY KEY CLUSTERED ([car_ms_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[carrier_moreSettings] ADD CONSTRAINT [fk_car_ms_ResourceID] FOREIGN KEY ([resource_id]) REFERENCES [dbo].[carrier] ([car_id])
GO
GRANT DELETE ON  [dbo].[carrier_moreSettings] TO [public]
GO
GRANT INSERT ON  [dbo].[carrier_moreSettings] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrier_moreSettings] TO [public]
GO
GRANT SELECT ON  [dbo].[carrier_moreSettings] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrier_moreSettings] TO [public]
GO
