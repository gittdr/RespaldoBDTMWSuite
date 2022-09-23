SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Object:  Stored Procedure dbo.load_label_sp    Script Date: 8/20/97 1:59:23 PM ******/

-- KM, PTS 8339, Call a new version of load_label_sp (bystatus) which takes a second argument
-- The second argument is @retired_flag (y or n)  Y means include retired, N means do not
--		include retired entries


create procedure [dbo].[load_label_sp] @name varchar(20)  as 

exec load_label_bystatus_sp @name, 'N'
GO
GRANT EXECUTE ON  [dbo].[load_label_sp] TO [public]
GO
