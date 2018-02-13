module "nodes" {
  source = ".."

  count = 3
  type  = "k1"
}
