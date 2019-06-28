output "id" {
  value = "${aws_instance.main.*.id}"
}

output "availability_zone" {
  value = "${aws_instance.main.*.availability_zone}"
}

output "placement_group" {
  value = "${aws_instance.main.*.placement_group}"
}

output "key_name" {
  value = "${aws_instance.main.*.key_name}"
}

output "password_data" {
  value = "${aws_instance.main.*.password_data}"
}

output "public_dns" {
  value = "${aws_instance.main.*.public_dns}"
}

output "public_ip" {
  value = "${aws_instance.main.*.public_ip}"
}

output "ipv6_addresses" {
  value = "${aws_instance.main.*.ipv6_addresses}"
}

output "network_interface_id" {
  value = "${aws_instance.main.*.network_interface_id}"
}

output "primary_network_interface_id" {
  value = "${aws_instance.main.*.primary_network_interface_id}"
}

output "private_dns" {
  value = "${aws_instance.main.*.private_dns}"
}

output "private_ip" {
  value = "${aws_instance.main.*.private_ip}"
}

output "security_groups" {
  value = "${aws_instance.main.*.security_groups}"
}

output "vpc_security_group_ids" {
  value = "${aws_instance.main.*.vpc_security_group_ids}"
}

output "subnet_id" {
  value = "${aws_instance.main.*.subnet_id}"
}

output "root_block_device" {
  value = "${aws_instance.main.*.root_block_device}"
}
