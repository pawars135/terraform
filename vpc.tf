#get availabity zones
data "aws_availability_zones" "az" {
    state="available"
  
}
# Vpc
resource "aws_vpc" "default"{
    cidr_block = "172.31.0.0/16"
}

# public subnet
resource "aws_subnet" "public"{
  count=2
  vpc_id= aws_vpc.default.id
  cidr_block= cidrsubnet(aws_vpc.default.cidr_block,8,2+count.index)
  availability_zone= data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch=true
}

#private subnet
resource "aws_subnet" "private"{
  count=2
  vpc_id=aws_vpc.default.id
  cidr_block=cidrsubnet(aws_vpc.default.cidr_block,8,count.index)
  availability_zone=data.aws_availability_zones.az.names[count.index]
}

#internet gateway
resource "aws_internet_gateway" "gateway"{
  vpc_id= aws_vpc.default.id
}

#route
resource "aws_route" "internet_access"{
  route_table_id=aws_vpc.default.main_route_table_id
  destination_cidr_block= "0.0.0.0/0"
  gateway_id=aws_internet_gateway.gateway.id
}
#elastic ip
resource "aws_eip" "gateway" {
  count=2
  vpc=true    
  depends_on= [aws_internet_gateway.gateway]
}

#NAT gateway
resource "aws_nat_gateway" "gateway"{
  count=2
  subnet_id= element(aws_subnet.public.*.id,count.index)
  allocation_id=element(aws_eip.gateway.*.id,count.index)
}

#route table
resource "aws_route_table" "private"{
  count=2
  vpc_id=aws_vpc.default.id
  route {
    cidr_block="0.0.0.0/0"
    nat_gateway_id= element(aws_nat_gateway.gateway.*.id, count.index)
  }
}

#route table association
resource "aws_route_table_association" "private"{
  count=2
  subnet_id=element(aws_subnet.private.*.id,count.index)
  route_table_id=element(aws_route_table.private.*.id,count.index)
}




