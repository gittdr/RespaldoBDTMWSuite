SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
create view [dbo].[actg_PayDetailView] as select * from paydetail --TMW STANDARD: Do not include this comment in any customer specific replacement!
GO
GRANT DELETE ON  [dbo].[actg_PayDetailView] TO [public]
GO
GRANT INSERT ON  [dbo].[actg_PayDetailView] TO [public]
GO
GRANT REFERENCES ON  [dbo].[actg_PayDetailView] TO [public]
GO
GRANT SELECT ON  [dbo].[actg_PayDetailView] TO [public]
GO
GRANT UPDATE ON  [dbo].[actg_PayDetailView] TO [public]
GO
