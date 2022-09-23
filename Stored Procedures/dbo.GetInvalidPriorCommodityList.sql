SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create proc [dbo].[GetInvalidPriorCommodityList] as
select distinct prior_cmd_code, invalid_cmd_code, IsPrevent
from (select distinct id, prior_cmd_code, IsPrevent from commodity_prior_rules where prior_cmd_code <> 'UNKNOWN'
union
select distinct id, commodity.cmd_code as prior_cmd_code, IsPrevent from commodity_prior_rules join commodity on commodity.cmd_class = prior_cmd_class 
	where prior_cmd_class <> 'UNKNOWN' and commodity.cmd_code <> 'UNKNOWN'
union
select distinct id, commodity.cmd_code as prior_cmd_code, IsPrevent from commodity_prior_rules join commodity on commodity.cmd_class2 = prior_cmd_class2 
	where prior_cmd_class2 <> 'UNKNOWN' and commodity.cmd_code <> 'UNKNOWN') as PriorCommodity,

(select distinct id, invalid_cmd_code, commodity_prior_rules.IsPrevent as IsPrevent2 from commodity_prior_rules where invalid_cmd_code <> 'UNKNOWN'
union
select distinct id, commodity.cmd_code as invalid_cmd_code, commodity_prior_rules.IsPrevent as IsPrevent2 from commodity_prior_rules join commodity on commodity.cmd_class = invalid_cmd_class 
	where invalid_cmd_class <> 'UNKNOWN' and commodity.cmd_code <> 'UNKNOWN'
union
select distinct id, commodity.cmd_code as invalid_cmd_code, commodity_prior_rules.IsPrevent as IsPrevent2 from commodity_prior_rules join commodity on commodity.cmd_class2 = invalid_cmd_class2 
	where invalid_cmd_class2 <> 'UNKNOWN' and commodity.cmd_code <> 'UNKNOWN') as InvalidCommodity
where PriorCommodity.id = InvalidCommodity.id
GO
GRANT EXECUTE ON  [dbo].[GetInvalidPriorCommodityList] TO [public]
GO
