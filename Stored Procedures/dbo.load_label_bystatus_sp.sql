SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  Stored Procedure dbo.load_label_bystatus_sp    Script Date: 8/20/97 1:59:23 PM ******/
create procedure [dbo].[load_label_bystatus_sp] 
@name varchar(20), 
@retired_flag varchar(1) as 

--vjh PTS42009 moved logic (with new argument) to load_label_bystatus_withrowsecurityoverride_sp
exec load_label_bystatus_withrowsecurityoverride_sp @name, 'N', 'N'

GO
GRANT EXECUTE ON  [dbo].[load_label_bystatus_sp] TO [public]
GO
