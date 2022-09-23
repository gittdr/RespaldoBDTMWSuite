CREATE TABLE [dbo].[no_touch_process_resource_eligibility]
(
[resource_type] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[resource_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[is_eligible] [bit] NOT NULL,
[lastupdateby] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[lastupdatedate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[no_touch_process_resource_eligibility] ADD CONSTRAINT [pk_no_touch_resource_eligibility] UNIQUE NONCLUSTERED ([resource_type], [resource_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[no_touch_process_resource_eligibility] TO [public]
GO
GRANT INSERT ON  [dbo].[no_touch_process_resource_eligibility] TO [public]
GO
GRANT REFERENCES ON  [dbo].[no_touch_process_resource_eligibility] TO [public]
GO
GRANT SELECT ON  [dbo].[no_touch_process_resource_eligibility] TO [public]
GO
GRANT UPDATE ON  [dbo].[no_touch_process_resource_eligibility] TO [public]
GO
