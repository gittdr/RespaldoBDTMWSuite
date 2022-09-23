CREATE TABLE [dbo].[completion_statemiles]
(
[ord_number] [char] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[state_code] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[state_start_odometer] [decimal] (8, 1) NULL,
[state_end_odometer] [decimal] (8, 1) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[completion_statemiles] ADD CONSTRAINT [PK_completion_statemiles] PRIMARY KEY CLUSTERED ([ord_number], [state_code]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[completion_statemiles] TO [public]
GO
GRANT INSERT ON  [dbo].[completion_statemiles] TO [public]
GO
GRANT REFERENCES ON  [dbo].[completion_statemiles] TO [public]
GO
GRANT SELECT ON  [dbo].[completion_statemiles] TO [public]
GO
GRANT UPDATE ON  [dbo].[completion_statemiles] TO [public]
GO
