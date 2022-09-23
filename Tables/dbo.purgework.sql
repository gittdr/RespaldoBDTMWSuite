CREATE TABLE [dbo].[purgework]
(
[mov_number] [int] NOT NULL
) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[purgework] TO [public]
GO
GRANT INSERT ON  [dbo].[purgework] TO [public]
GO
GRANT REFERENCES ON  [dbo].[purgework] TO [public]
GO
GRANT SELECT ON  [dbo].[purgework] TO [public]
GO
GRANT UPDATE ON  [dbo].[purgework] TO [public]
GO
