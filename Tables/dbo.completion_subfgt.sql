CREATE TABLE [dbo].[completion_subfgt]
(
[subfgt_id] [int] NOT NULL IDENTITY(1, 1),
[subfgt_pickup_number] [int] NULL,
[subfgt_drop_number] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[completion_subfgt] ADD CONSTRAINT [PK__completion_subfg__64866ADB] PRIMARY KEY CLUSTERED ([subfgt_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[completion_subfgt] TO [public]
GO
GRANT INSERT ON  [dbo].[completion_subfgt] TO [public]
GO
GRANT REFERENCES ON  [dbo].[completion_subfgt] TO [public]
GO
GRANT SELECT ON  [dbo].[completion_subfgt] TO [public]
GO
GRANT UPDATE ON  [dbo].[completion_subfgt] TO [public]
GO
